defmodule WhereMachines.AutoSpawner do
  use GenServer
  require Logger
  alias WhereMachines.MachineLauncher

  @default_interval 60_000  # 1 minute default
  @jitter_factor 0.2        # 20% jitter
  @default_regions [:ams, :ord, :syd, :sin, :lax, :yyz, :lhr, :fra]
  @pubsub_topic "machine_updates"

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
    enabled = Keyword.get(opts, :auto_start, true)

    state = %{
      interval: interval,
      regions: regions,
      enabled: enabled,
      next_region_index: 0,
      last_spawn_time: nil
    }

    if enabled do
      schedule_next_spawn(interval)
    end

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
  # Private helpers
  defp schedule_next_spawn(interval) do
    Process.send_after(self(), :spawn_machine, interval)
  end

  defp try_spawn_machine(region) do
    region_str = Atom.to_string(region)
    # We use "auto-spawner" as the id for all auto-spawned machines
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
