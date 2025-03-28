defmodule WhereMachines.MachineTracker do
  use GenServer
  require Logger

  @table_name :useless_machine_status
  @cleanup_interval :timer.minutes(10)
  @prune_stopped_after :timer.minutes(30)  # How long to keep stopped machine records
  @app_name "useless-machine"

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Update the status of a machine
  """
  def update_status(machine_id, status_map) do
    GenServer.cast(__MODULE__, {:update_status, machine_id, status_map})
  end

  @doc """
  Get the current status of all machines
  """
  def get_all_machines do
    :ets.tab2list(@table_name)
    |> Enum.map(fn {id, data} -> Map.put(data, :id, id) end)
  end

  @doc """
  Get the status of a specific machine
  """
  def get_machine(machine_id) do
    case :ets.lookup(@table_name, machine_id) do
      [{^machine_id, data}] -> {:ok, data}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  Count machines by status, returning a map of counts by region
  """
  def region_stats do
    # Get active machines (with "started" status)
    active_machines = get_all_machines()
    |> Enum.filter(fn machine -> machine.status == "started" end)

    # Group by region
    region_map = active_machines
    |> Enum.group_by(fn machine -> machine.region end)
    |> Enum.map(fn {region, machines} -> {region, length(machines)} end)
    |> Enum.into(%{})

    # Return total count and regions list
    {Enum.count(active_machines), Map.keys(region_map), region_map}
  end

  @doc """
  Get coordinates for active regions to display on the map
  """
  def get_active_region_coords(bbox) do
    # Get regions with active machines
    {_, regions, _} = region_stats()

    # Convert region codes to coordinates for the map
    regions
    |> Enum.map(fn region ->
      try do
        region_atom = String.to_existing_atom(region)
        WhereMachines.CityData.city_to_svg(region_atom, bbox)
      rescue
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # Server Callbacks

  @impl true
  def init(_) do
    # Create ETS table to store machine status
    :ets.new(@table_name, [:set, :named_table, :public, read_concurrency: true])

    # Schedule periodic cleanup
    schedule_cleanup()

    # Schedule periodic sync with API (every 10 minutes)
    schedule_sync()

    {:ok, %{client: setup_api_client()}}
  end

  # Setup API client
  defp setup_api_client do
    Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
  end

  # Schedule sync timer
  defp schedule_sync do
    Process.send_after(self(), :sync_with_api, :timer.minutes(10))
  end


  @impl true
  def handle_cast({:update_status, machine_id, status_map}, state) do
    # Add timestamp if not provided
    status_map = Map.put_new(status_map, :timestamp, DateTime.utc_now() |> DateTime.to_iso8601())

    # Store in ETS
    :ets.insert(@table_name, {machine_id, status_map})

    # Broadcast the status update
    Phoenix.PubSub.broadcast(:where_pubsub, "machine_status", {:machine_status_changed, machine_id, status_map})
    {:noreply, state}
  end

  # Handle scheduled sync
  @impl true
  def handle_info(:sync_with_api, %{client: client} = state) do
    # Perform sync
    _ = sync_with_api(client)

    # Schedule next sync
    schedule_sync()

    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup_stale_machines, state) do
    now = DateTime.utc_now()

    # Find machines with stale statuses
    all_machines = get_all_machines()

    for machine <- all_machines do
      case DateTime.from_iso8601(machine.timestamp) do
        {:ok, timestamp, _} ->
          # If a machine hasn't updated in 20 minutes and is still "started",
          # assume it died without sending a "stopping" update
          if DateTime.diff(now, timestamp, :minute) > 20 && machine.status == "started" do
            Logger.info("Cleaning up stale machine: #{machine.id}")
            :ets.delete(@table_name, machine.id)

            # Broadcast the cleanup
            Phoenix.PubSub.broadcast(:where_pubsub, "machine_status", {:machine_status_changed, machine.id, %{status: "disappeared"}})
          end
        _ ->
          # Invalid timestamp, remove this entry
          :ets.delete(@table_name, machine.id)
      end

      # Remove machines that have been stopped for more than 30 minutes
      if machine.status == "stopping" do
        case DateTime.from_iso8601(machine.timestamp) do
          {:ok, timestamp, _} ->
            if DateTime.diff(now, timestamp, :minute) > 30 do
              Logger.info("Removing stopped machine: #{machine.id}")
              :ets.delete(@table_name, machine.id)
            end
          _ ->
            :ok
        end
      end
    end

    # Schedule next cleanup
    schedule_cleanup()

    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup_stale_machines, @cleanup_interval)
  end

  # In MachineTracker
def sync_with_api(client) do
  Logger.info("Syncing machine states with Fly.io API")

  # Get current tracked machines
  current_machines = get_all_machines() |> Enum.map(fn m -> {m.id, m} end) |> Map.new()

  # Get machines from API
  case Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
    {:ok, api_machines} ->
      # Process each API machine
      for machine <- api_machines do
        machine_id = machine["id"]

        # Check if this machine is already in our tracker
        case Map.get(current_machines, machine_id) do
          nil ->
            # Machine exists in API but not in our tracker - add it
            update_status(machine_id, %{
              status: map_api_status(machine["state"]),
              region: machine["region"],
              timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
            })

          existing ->
            # Machine exists in both - only update if API is newer
            # This preserves our "stopping" status which might not be reflected in API
            if existing.status != "stopping" do
              update_status(machine_id, %{
                status: map_api_status(machine["state"]),
                region: machine["region"],
                timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
              })
            end
        end
      end

      # Find machines that exist in our tracker but not in API
      api_ids = MapSet.new(api_machines, fn m -> m["id"] end)
      for {id, machine} <- current_machines, not MapSet.member?(api_ids, id) do
        # If machine is not "stopping" and was last updated more than 5 minutes ago,
        # consider it gone and remove it
        case DateTime.from_iso8601(machine.timestamp) do
          {:ok, timestamp, _} ->
            diff_minutes = DateTime.diff(DateTime.utc_now(), timestamp, :second) / 60
            if machine.status != "stopping" && diff_minutes > 5 do
              # Remove from tracker
              :ets.delete(@table_name, id)
              Logger.info("Removed stale machine from tracker: #{id}")

              # Broadcast the cleanup
              Phoenix.PubSub.broadcast(:where_pubsub, "machine_status", {:machine_status_changed, id, %{status: "disappeared"}})
            end
          _ ->
            # Invalid timestamp - remove
            :ets.delete(@table_name, id)
        end
      end

      # Broadcast that sync is complete
      Phoenix.PubSub.broadcast(:where_pubsub, "machine_status", {:machines_synced})
      {:ok, api_machines}

    {:error, reason} ->
      Logger.error("Failed to sync with Fly.io API: #{inspect(reason)}")
      {:error, reason}
  end
end

# Helper to map API machine state to our status format
defp map_api_status("started"), do: "started"
defp map_api_status("running"), do: "started"
defp map_api_status("stopping"), do: "stopping"
defp map_api_status("stopped"), do: "stopping"
defp map_api_status(other), do: other
end
