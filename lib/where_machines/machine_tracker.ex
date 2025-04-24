defmodule WhereMachines.MachineTracker do
  use GenServer
  require Logger

  @app_name "useless-machine"
  @table_name :useless_machines
  @api_check_interval :timer.seconds(60)
  @debounce_interval :timer.seconds(2)
  @min_refresh_interval :timer.seconds(5)  # Minimum time between API refreshes
  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def update_all_from_api() do
    Logger.debug("MachineTracker update_all_from_api invoked; sending :debounced_update message")
    GenServer.cast(__MODULE__, :debounced_update)
  end

  @doc """
  Gets an up-to-date count of machines, triggering an API refresh if needed.
  If the last refresh was recent enough, returns the current count without an API call.

  Returns a tuple with the count and a boolean indicating if it was refreshed:
  {:ok, count, refreshed?}
  """
  def get_fresh_count() do
    GenServer.call(__MODULE__, :get_fresh_count, 10_000)
  end

  @doc """
  Read the current status of all machines from the ETS table.

  :ets.tab2list(@table_name) #=> [
  {"84e475f2730298",
   %{status: "started", timestamp: "2025-04-02T18:13:58.220533Z", region: "ord"}},
  {"48eddeef744d58",
   %{status: "created", timestamp: "2025-04-02T18:14:27.554385Z", region: "yyz"}}
  ]
  """
  def look_up_all_machines do
    :ets.tab2list(@table_name)
    |> Map.new(fn {id, status_map} -> {id, status_map} end)
  end

  def count_machines do
    :ets.info(@table_name, :size)
  end

  @doc """
  Read the status of a specific machine from the ETS table.
  Not tested since not used yet.
  """
  def look_up_machine(machine_id) do
    case :ets.lookup(@table_name, machine_id) do
      [{^machine_id, data}] -> {:ok, data}
      [] -> {:error, :not_found}
    end
  end

  #######################################################################################
  # Server Callbacks
  #######################################################################################

  @impl true
  def init(_) do
    # Create ETS table to store machine status
    :ets.new(@table_name, [:set, :named_table, :public, read_concurrency: true])
    Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")
    Logger.debug("In MachineTracker init")
    # Initial population from API
    send(self(), :update_all_from_api)
    # schedule_api_check()
    {:ok, %{
      update_ref: nil,
      last_api_refresh: nil,
      refresh_in_progress: false,
      pending_callers: []
    }}
  end

#######################################################################################
# Handle calls for a fresh Machine count (so we don't always do an API call bu we'll
# wait for one if it's in progress or it's been long enough to start a fresh one)
#######################################################################################

@impl true
def handle_call(:get_fresh_count, from, state) do
  now = System.monotonic_time(:millisecond)
  needs_refresh = case state.last_api_refresh do
    nil -> true  # Never refreshed
    timestamp -> (now - timestamp) > @min_refresh_interval
  end

  cond do
    # No refresh needed - return current count immediately
    not needs_refresh ->
      count = count_machines()
      Logger.debug("Returning cached machine count: #{count}")
      {:reply, {:ok, count, false}, state}

    # Refresh already in progress - add caller to pending list
    state.refresh_in_progress ->
      Logger.debug("Refresh in progress, adding caller to pending list")
      {:noreply, %{state | pending_callers: [from | state.pending_callers]}}

    # Need to refresh and none in progress - trigger refresh
    true ->
      Logger.debug("Triggering API refresh for fresh count")
      send(self(), :update_for_fresh_count)
      # Set a timeout to ensure callers don't get stuck
      Process.send_after(self(), :refresh_timeout, 4_500)
      {:noreply, %{state |
        refresh_in_progress: true,
        pending_callers: [from | (state.pending_callers || [])]
      }}
  end
end

  #######################################################################################
  # Handle casts for debouncing
  #######################################################################################
  @impl true
  def handle_cast(:debounced_update, %{update_ref: ref} = state) do
    # Cancel any existing timer
    if ref, do: Process.cancel_timer(ref)

    now = System.monotonic_time(:millisecond)
    needs_refresh = case state.last_api_refresh do
      nil -> true  # Never refreshed
      timestamp -> (now - timestamp) > @min_refresh_interval
    end

    if needs_refresh do
      # Leading edge - execute immediately if it's been long enough
      Logger.debug("Tracker sending self :update_all_from_api")
      send(self(), :update_all_from_api)
      new_ref = Process.send_after(self(), :reset_debounce, @debounce_interval)
      {:noreply, %{state | update_ref: new_ref}}
    else
      # Otherwise, schedule for later (trailing edge)
      Logger.debug("Too soon for another API call - scheduling for later")
      new_ref = Process.send_after(self(), :update_all_from_api, @debounce_interval)
      {:noreply, %{state | update_ref: new_ref}}
    end
  end

  #######################################################################################
  # Handle messages sent by this module to itself
  #######################################################################################
  @impl true
  def handle_info(:run_sched_api_check, state) do
    # First schedule the next one
    schedule_api_check()
    send(self(), :update_all_from_api)
    {:noreply, state}
  end


  @impl true
  def handle_info(:update_for_fresh_count, state) do
    # Special case for getting a fresh count - will respond to all pending callers
    Logger.debug("Tracker sending self :update_all_from_api for fresh count")
    send(self(), :update_all_from_api)
    {:noreply, state}
  end

  @impl true
  def handle_info(:reset_debounce, state) do
    Logger.debug("Resetting debounce timer")
    {:noreply, %{state | update_ref: nil}}
  end


  @impl true
  def handle_info(:update_all_from_api, state) do
    Logger.debug("MachineTracker received :update_all_from_api message.")
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
    api_entries = case Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
      {:ok, api_machines} ->
        api_machines
          |> Enum.map(fn machine ->
            {machine["id"],
            %{
              status: map_api_status(machine["state"]),
              region: machine["region"],
              timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
            }}
          end)
      {:error, reason} ->
        # Handle error - maybe log it, maybe retry later
        Logger.error("Failed to get machines from API: #{inspect(reason)}")
        # Optionally schedule a retry
        #Process.send_after(self(), :populate_ets, 5_000)
        []
    end
    # Using MapSets instead of Enum.filter for comparisons-- more efficient, which
    # won't matter, but let's practice the skill
    api_ids = MapSet.new(api_entries, fn {first, _} -> first end)
    current_ids = look_up_all_machines() |> Enum.map(fn {id, _status_map} -> id end) |> MapSet.new()
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
    #
    # We've just done an API call and we're going to naively accept the API response
    # as truth for our tracker table.
    #
    # Remove entries that weren't in the API list
    tracker_only
    |> Enum.map(fn machine_id ->
      :ets.delete(@table_name, machine_id)
      Logger.debug("MachineTracker removed machine #{machine_id}")
      Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_removed, machine_id})
    end)
    # Overwrite all entries with the API version (:etc.insert is an upsert
    # and treats the first element of the tuple as a key to the entry).
    # This'll add any Machines that weren't already in the table, too.
    api_entries
    |> Enum.map(fn {machine_id, status_map} ->
      :ets.insert(@table_name, {machine_id, status_map})
      Logger.debug("MachineTracker added or overwrote Machine #{machine_id}")
      Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:replaced_from_api, {machine_id, status_map}})
    end)

    # Get the current count after update
    current_count = count_machines()

    # Respond to any pending callers, even if there was an error
    if Map.has_key?(state, :pending_callers) && state.pending_callers && length(state.pending_callers) > 0 do
      state.pending_callers
      |> Enum.each(fn caller ->
        GenServer.reply(caller, {:ok, current_count, true})
        Logger.debug("Replying to pending caller with fresh count: #{current_count}")
      end)
    end

    # Update state - reset references and record refresh time
    now = System.monotonic_time(:millisecond)
    new_state = %{
      state |
      update_ref: nil,
      last_api_refresh: now,
      refresh_in_progress: false,
      pending_callers: []
    }

    {:noreply, new_state}
  end

  #######################################################################################
  # Handle PubSub messages on the "machine_updates" topic from the cluster (including this node)
  #######################################################################################

  @impl true
  def handle_info({:machine_added, {machine_id, status_map}}, state) do
    Logger.info("Tracker got :machine_added message by PubSub from Launcher component")
    :ets.insert(@table_name, {machine_id, status_map})
    {:noreply, state}
  end

  @impl true
  def handle_info({:machine_started, {machine_id, status_map}}, state) do
    Logger.info("Tracker got :machine_started message by PubSub from Launcher component")
    :ets.insert(@table_name, {machine_id, status_map})
    {:noreply, state}
  end

  # Timeout handler to make sure callers don't get stuck:
  @impl true
  def handle_info(:refresh_timeout, state) do
    if state.refresh_in_progress && length(state.pending_callers) > 0 do
      Logger.warning("Refresh operation timed out, responding to pending callers with current count")
      current_count = count_machines()

      state.pending_callers
      |> Enum.each(fn caller ->
        GenServer.reply(caller, {:ok, current_count, false})
      end)
    end

    {:noreply, %{state | refresh_in_progress: false, pending_callers: []}}
  end

  # When we hear a Machine is ready, update its state (insert if it's not already there)
  @impl true
  def handle_info({:machine_ready, {machine_id, status_map}}, state) do
    Logger.info("MachineTracker: :machine_ready for #{machine_id} from status controller via local PubSub")
    :ets.insert(@table_name, {machine_id, status_map})
    {:noreply, state}
  end

  # Remove a finished Machine from the table
  @impl true
  def handle_info({:machine_stopping, machine_id}, state) do
    Logger.info("MachineTracker: PubSub :machine_stopping message received from controller")
    :ets.delete(@table_name, machine_id)
    {:noreply, state}
  end

    # Ignore anything else
    @impl true
    def handle_info(message, state) do
      Logger.debug("MachineTracker ignoring #{inspect message} from PubSub")
      {:noreply, state}
    end


  # Helper to map API machine state to our status format
  defp map_api_status("started"), do: "started"
  defp map_api_status("stopping"), do: "stopping"
  defp map_api_status("stopped"), do: "stopping"
  defp map_api_status(other), do: other

  defp schedule_api_check do
    Logger.info("Scheduling the next api check in #{@api_check_interval/1000}s")
    Process.send_after(self(), :run_sched_api_check, @api_check_interval)
  end
end
