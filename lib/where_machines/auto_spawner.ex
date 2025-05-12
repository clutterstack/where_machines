defmodule WhereMachines.AutoSpawner do
  use GenServer
  require Logger
  alias WhereMachines.MachineLauncher

  @default_interval 60_000  # 1 minute default
  @jitter_factor 0.2        # 20% jitter
  @default_regions [:ams, :ord, :syd, :sin, :lax, :yyz, :lhr, :fra]
  @pubsub_topic "machine_updates"
  @reconciliation_interval 30_000  # Check every 30 seconds
  @inactivity_timeout 60_000  # 1 minute of no activity


  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enable do
    GenServer.cast(__MODULE__, :enable)
  end

  def disable do
    GenServer.cast(__MODULE__, :disable)
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Server Callbacks
  def init(opts) do
    interval = Keyword.get(opts, :interval, @default_interval)
    regions = Keyword.get(opts, :regions, @default_regions)
    # Default to disabled until we receive a visitor
    enabled = false

    # Subscribe to presence changes
    Phoenix.PubSub.subscribe(:where_pubsub, "presence_diff:visitors")
    Phoenix.PubSub.subscribe(:where_pubsub, "presence_state:visitors")

    Logger.debug("AutoSpawner starting. Waiting for visitors.")
    Logger.debug("AutoSpawner starting. Enabled? #{inspect enabled}")

    state = %{
      interval: interval,
      regions: regions,
      enabled: false,
      next_region_index: 0,
      last_spawn_time: nil,
      visitors: %{},  # Use a map to store actual presence information
      last_activity_time: DateTime.utc_now(),
      activity_timer_ref: nil
    }

    # Schedule periodic reconciliation
    schedule_reconciliation()

    {:ok, state}
  end

  def handle_cast(:enable, state) do
    unless state.enabled do
      schedule_next_spawn(state.interval)
    end
    {:noreply, %{state | enabled: true}}
  end

  def handle_cast(:disable, state) do
    {:noreply, %{state | enabled: false}}
  end

  def handle_call(:status, _from, state) do
    {:reply, %{
      enabled: state.enabled,
      interval: state.interval,
      regions: state.regions,
      next_region_index: state.next_region_index,
      last_spawn_time: state.last_spawn_time
    }, state}
  end

  # Removed the custom :visitor_connected handler as we're using Phoenix Presence


  # Add a handler for full presence state updates
  def handle_info(%{event: "presence_state", state: presence_state}, state) do
    visitor_count = map_size(presence_state) |> dbg

    new_state = cond do
      # First visitor arrives
      visitor_count > 0 and not state.enabled ->
        Logger.info("Visitors present (#{visitor_count}). Enabling AutoSpawner.")
        Process.send(self(), :spawn_machine, [])
        schedule_next_spawn(state.interval)
        %{state | enabled: true, visitors: presence_state}

      # Last visitor leaves
      visitor_count == 0 and state.enabled ->
        Logger.info("No more visitors. Disabling AutoSpawner.")
        %{state | enabled: false, visitors: %{}}

      # Just update the presence state
      true ->
        %{state | visitors: presence_state}
    end

    {:noreply, new_state}
  end

  # Update the diff handler to update the presence map correctly
  def handle_info(%{event: "presence_diff", joins: joins, leaves: leaves}, state) do
    Logger.debug("Visitor presence changed: #{map_size(joins)} joins and #{map_size(leaves)} leaves")

    # Update presence map based on joins and leaves
    visitors = state.visitors
               |> Map.merge(joins)
               |> Map.drop(Map.keys(leaves))

    visitor_count = map_size(visitors)

    # Enable/disable based on visitor count
    new_state = cond do
      # First visitor arrives
      visitor_count > 0 and not state.enabled ->
        Logger.info("Visitors present (#{visitor_count}). Enabling AutoSpawner.")
        Process.send(self(), :spawn_machine, [])
        schedule_next_spawn(state.interval)
        %{state | enabled: true, visitors: visitors}

      # Last visitor leaves
      visitor_count == 0 and state.enabled ->
        Logger.info("No more visitors. Disabling AutoSpawner.")
        %{state | enabled: false, visitors: %{}}

      # Just update the presence map
      true ->
        %{state | visitors: visitors}
    end

     # Cancel existing timer if there is one
     if state.activity_timer_ref, do: Process.cancel_timer(state.activity_timer_ref)

     # Set up new timer only if we're enabled and have visitors
     activity_timer_ref = if visitor_count > 0 do
       Process.send_after(self(), :check_inactivity, @inactivity_timeout)
     else
       nil
     end

     new_state = %{new_state |
       last_activity_time: DateTime.utc_now(),
       activity_timer_ref: activity_timer_ref
     }

    {:noreply, new_state}
  end

  def handle_info(:reconcile_presence, state) do
    # Request current presence state from the tracker
    # This depends on how your presence system is implemented
    # Here's a generic approach:
    current_presence = WhereMachinesWeb.Presence.list("visitors")
    visitor_count = map_size(current_presence)

    # Update state based on actual presence
    new_state = cond do
      visitor_count > 0 and not state.enabled ->
        Logger.info("Reconciliation: Visitors present (#{visitor_count}). Enabling AutoSpawner.")
        Process.send(self(), :spawn_machine, [])
        schedule_next_spawn(state.interval)
        %{state | enabled: true, visitors: current_presence}

      visitor_count == 0 and state.enabled ->
        Logger.info("Reconciliation: No visitors found. Disabling AutoSpawner.")
        %{state | enabled: false, visitors: %{}}

      true ->
        %{state | visitors: current_presence}
    end

    # Schedule the next reconciliation
    schedule_reconciliation()

    {:noreply, new_state}
  end


  def handle_info(:spawn_machine, %{enabled: false} = state) do
    # Don't schedule another spawn if disabled
    {:noreply, state}
  end

  def handle_info(:spawn_machine, %{enabled: true} = state) do
    # Select the next region in rotation
    region = Enum.at(state.regions, state.next_region_index)
    next_index = rem(state.next_region_index + 1, length(state.regions))

    # Attempt to spawn a machine
    spawn_result = try_spawn_machine(region)
    log_spawn_attempt(region, spawn_result)

    # Broadcast creation event if successful
    case spawn_result do
      {:ok, %{machine_id: id, status_map: status_map}} ->
        Phoenix.PubSub.broadcast(
          :where_pubsub,
          @pubsub_topic,
          {:machine_added, {id, status_map}}
        )
      _ -> :ok
    end

    # Calculate next interval with jitter
    jitter = :rand.uniform() * @jitter_factor * 2 - @jitter_factor
    next_interval = round(state.interval * (1 + jitter))

    # Schedule next spawn
    schedule_next_spawn(next_interval)

    {:noreply, %{state |
      next_region_index: next_index,
      last_spawn_time: DateTime.utc_now()
    }}
  end

  def handle_info(:check_inactivity, state) do
    now = DateTime.utc_now()
    elapsed = DateTime.diff(now, state.last_activity_time, :millisecond)

    if elapsed >= @inactivity_timeout and state.enabled do
      Logger.warning("No activity detected for #{elapsed}ms. Safety disabling AutoSpawner.")
      new_state = %{state | enabled: false, activity_timer_ref: nil}
      {:noreply, new_state}
    else
      # Still active, reset the timer
      timer_ref = Process.send_after(self(), :check_inactivity, @inactivity_timeout)
      {:noreply, %{state | activity_timer_ref: timer_ref}}
    end
  end


  defp schedule_reconciliation do
    Process.send_after(self(), :reconcile_presence, @reconciliation_interval)
  end

  # Private helpers
  defp schedule_next_spawn(interval) do
    Logger.info("Scheduling next autospawn in #{interval} ms")
    Process.send_after(self(), :spawn_machine, interval)
  end

  defp try_spawn_machine(region) do
    region_str = Atom.to_string(region)
    # We use "auto-spawner" as the id for all auto-spawned machines
    Logger.debug("AutoSpawner is about to spawn a Machine in #{region_str}")
    MachineLauncher.maybe_spawn_useless_machine("auto-spawner", region_str)
  end

  defp log_spawn_attempt(region, result) do
    case result do
      {:ok, %{machine_id: id, status_map: %{region: actual_region}}} ->
        Logger.debug("AutoSpawner successfully launched machine #{id} in #{actual_region} (requested: #{region})")
      {:error, %{reason: reason}} ->
        Logger.warning("AutoSpawner failed to launch machine in #{region}: #{reason}")
      _ ->
        Logger.error("AutoSpawner received unexpected response: #{inspect(result)}")
    end
  end
end
