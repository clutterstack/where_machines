defmodule WhereMachines.MachineTracker do
  use GenServer
  require Logger

  @app_name "useless-machine"
  @table_name :useless_machines
  @cleanup_interval :timer.seconds(300) # How long to keep stopped machine records

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Tell self to handle an update from a Machine to the HTTP endpoint.
  This is invoked by the MachineStatusController module when it receives
  an update directly from a Useless Machine by HTTP.

  status_map is expected to be of the form
  %{status: status, region: region, timestamp: timestamp}
  """
  def update_from_http(machine_id, status_map) do
    Logger.info("MachineTracker update_from_http invoked for machine #{machine_id}; casting :update_from_http message")
    GenServer.cast(__MODULE__, {:update_from_http, machine_id, status_map})
  end

  @doc """
  Call the api for a list of Machines and then update the table with them
  """
  def call_api_and_update() do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
    {:ok, api_machines} = Clutterfly.Commands.get_mach_summaries(@app_name, client: client)
    update_all_from_api(api_machines)
  end

  @doc """
  When IndexLive does its API call, the callback will replace the whole local useless_machines table with the results of that.
  Also want to broadcast on the local PubSub topic so this node's LiveView knows to update its assigns.
  """
  def update_all_from_api(api_machines) do
    Logger.info("MachineTracker update_all_from_api invoked; casting :update_all_from_api message")
    GenServer.cast(__MODULE__, {:update_all_from_api, api_machines})
  end

  @doc """
  Read the current status of all machines from the ETS table.
  """
  def get_all_machines do
    :ets.tab2list(@table_name)
    |> Enum.map(fn {id, data} -> Map.put(data, :id, id) end)
  end

  @doc """
  Read the status of a specific machine from the ETS table.
  Not tested since not used yet.
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
    count_by_region = active_machines
    |> Enum.group_by(fn machine -> machine.region end)
    |> Enum.map(fn {region, machines} -> {region, length(machines)} end)
    |> Enum.into(%{}) # list to map

    # Return total count and regions list
    {Enum.count(active_machines), Map.keys(count_by_region), count_by_region}
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
        # region_atom = String.to_existing_atom(region)
        WhereMachines.CityData.city_to_svg(region, bbox)
      rescue
        _ -> Logger.info("MachineTracker.get_active_region_coords went wrong.")
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # Server Callbacks

  @impl true
  def init(_) do
    # Create ETS table to store machine status
    :ets.new(@table_name, [:set, :named_table, :public, read_concurrency: true])
    Phoenix.PubSub.subscribe(:where_pubsub, "um_table")
    # Initial population of table
    call_api_and_update()
    # Schedule periodic cleanup
    # schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  # Our Useless Machine says it's started up.
  # Broadcast locally so the LiveView knows to forward the browser to it.
  # Broadcast to cluster so all MachineTrackers can add it to their table.
  def handle_cast({:update_from_http, machine_id,  %{status: "started"} = status_map}, state) do
    Logger.info("MachineTracker handling :update_from_http message for a started Machine.")
    broadcast_local_table_updated(:machine_ready)
    Phoenix.PubSub.broadcast(:where_pubsub, "um_table", {:machine_added, machine_id, status_map})
    {:noreply, state}
  end

  # Our Machine says it's shutting down.
  # Broadcast to cluster so all MachineTrackers can remove it from their table
  def handle_cast({:update_from_http, machine_id, %{status: "stopping"}}, state) do
    Logger.info("MachineTracker handling :update_from_http message for a stopping Machine")
    # Broadcast the status update
    Phoenix.PubSub.broadcast(:where_pubsub, "um_table", {:machine_stopped, machine_id})
    {:noreply, state}
  end

  def handle_cast({:update_all_from_api, api_machines}, state) do
    api_entries = api_machines
        |> Enum.map(fn machine ->
          {machine["id"],
          %{
            status: map_api_status(machine["state"]),
            region: machine["region"],
            timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
          }}
        end)
    # Using MapSets instead of Enum.filter for comparisons-- more efficient, which
    # won't matter, but let's practice the skill
    api_ids = MapSet.new(api_entries, fn {first, _} -> first end)

    current_ids = get_all_machines() |> Enum.map(fn m -> m.id end) |> MapSet.new()

    # Get IDs that are only in one set or the other
    # api_only = MapSet.difference(api_ids, current_ids) |> MapSet.to_list()
    tracker_only = MapSet.difference(current_ids, api_ids) |> MapSet.to_list()

    # Remove Machines from our tracker table if they weren't in the list
    # returned by the API. This might be terrible for a service discovery application
    # since API calls are slow.
    # A bit of a contradiction because we are literally using an API call as the source of
    # truth for available capacity (in this case it doesn't matter too much if we
    # start a couple extra Useless Machines; the idea is they're really fleeting)
    #
    # We're using PubSub and the API combined to update the map, which could cause
    # the map occasionally to get _less_ up-to-date. We're accepting this for now.


    # We've just done an API call and we're going to naively accept the API response
    # as truth for our tracker table.

    # Remove entries that weren't in the API list
    tracker_only
    |> Enum.map(fn machine_id ->
      :ets.delete(@table_name, machine_id)
      Logger.info("Removed machine from tracker: #{machine_id}")
    end)

    # Overwrite all entries with the API version (:etc.insert is an upsert
    # and treats the first element of the tuple as a key to the entry).
    # This'll add any Machines that weren't already in the table, too.
    api_entries
    |> Enum.map(fn {machine_id, status_map} ->
      :ets.insert(@table_name, {machine_id, status_map})
      Logger.info("Added or overwrote Machine #{machine_id} with API result")
    end)

    # Broadcast to our local node's topic that the table changed
    # this_machine = System.get_env("FLY_MACHINE_ID")
    # Phoenix.PubSub.broadcast(:where_pubsub, "to:#{this_machine}", {:table_updated_from_api})
    broadcast_local_table_updated(:replaced_from_api)
    {:noreply, state}

  end
  #######################################################################################
  # Handle PubSub messages on the "um_table" topic from the cluster (including this node)
  #######################################################################################

  # Insert a new Machine into the table and tell the local topic the table's updated
  @impl true
  def handle_info({:machine_added, machine_id, status_map}, state) do
    Logger.info("PubSub :machine_added message received")
    # Store in ETS
    :ets.insert(@table_name, {machine_id, status_map})
    broadcast_local_table_updated(:machine_added)
    {:noreply, state}
  end

  # Remove a finished Machine from the table and tell the local topic the table's updated
  @impl true
  def handle_info({:machine_stopped, machine_id}, state) do
    Logger.info("PubSub :machine_stopped message received")
    # Remove from ETS
    :ets.delete(@table_name, machine_id)
    broadcast_local_table_updated(:machine_removed)
    {:noreply, state}

  end

  # Handle a message sent from this module saying it's time to clear out stale Machines
  # from the table
  @impl true
  def handle_info(:clean_up_stale_machines, state) do
    now = DateTime.utc_now()

    # Find machines with stale statuses in ETS
    all_machines = get_all_machines()

    for machine <- all_machines do
      case DateTime.from_iso8601(machine.timestamp) do
        {:ok, timestamp, _} ->
          # If a machine hasn't updated in 5 minutes and is still "started",
          # assume it died without sending a "stopping" update
          if DateTime.diff(now, timestamp, :minute) > 5 && machine.status == "started" do
            Logger.info("MachineTracker cleaning up stale machine: #{machine.id}")
            :ets.delete(@table_name, machine.id)
          end
        _ ->
          # Invalid timestamp, remove this entry
          :ets.delete(@table_name, machine.id)
      end

      # Remove machines that have been stopped for more than 1 minute
      if machine.status == "stopping" do
        case DateTime.from_iso8601(machine.timestamp) do
          {:ok, timestamp, _} ->
            if DateTime.diff(now, timestamp, :minute) > 1 do
              Logger.info("Removing stopped machine: #{machine.id}")
              :ets.delete(@table_name, machine.id)
            end
          _ ->
            :ok
        end
      end
      # Broadcast that cleanup has happened
      broadcast_local_table_updated(:cleanup)
    end

    # Schedule next cleanup
    schedule_cleanup()

    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :clean_up_stale_machines, @cleanup_interval)
  end

  defp broadcast_local_table_updated(message) do
    this_machine = System.get_env("FLY_MACHINE_ID")
    Phoenix.PubSub.broadcast(:where_pubsub, "to:#{this_machine}", {:table_updated, message})
  end

  # Helper to map API machine state to our status format
  defp map_api_status("started"), do: "started"
  defp map_api_status("stopping"), do: "stopping"
  defp map_api_status("stopped"), do: "stopping"
  defp map_api_status(other), do: other

end
