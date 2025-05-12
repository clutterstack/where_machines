defmodule WhereMachinesWeb.WhereLive do
  use WhereMachinesWeb, :live_view

  alias WhereMachines.{CityData, MachineTracker}
  alias WhereMachinesWeb.{RegionMap, DashComponents}

  require Logger

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    if connected?(socket) do
      # Subscribe to machine status updates
      Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")
      # Track this connection with Presence
      WhereMachinesWeb.Presence.track(
        self(),
        "visitors",
        socket.id,
        %{
          connected_at: DateTime.utc_now(),
          region: fly_edge_region
        }
      )

      # Notify AutoSpawner of new visitor
      Phoenix.PubSub.broadcast(:where_pubsub, "visitor_events", {:visitor_connected, socket.id})
    end

    Logger.info("LiveView mounted in #{fly_edge_region}")

    # Check which version the route wants
    live_action = socket.assigns.live_action

    # Populate Machines list from the ETS table
    initial_machines = MachineTracker.look_up_all_machines()

    {:ok, assign(socket,
      fly_edge_region: fly_edge_region,
      regions: regions_for_action(live_action),
      umachines: initial_machines,
      our_mach: %{},
      our_mach_state: nil,
      page_title: "Where Machines",
      # Add timer state
      timer_ref: nil,
      current_timer_display: "0.0s",
      active_timer_button: nil
     )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class="min-h-screen grid grid-cols-4 gap-x-8 w-full pt-8 sm:pt-12 content-start">

      <h1 class="text-2xl sm:text-3xl font-mono font-bold text-[#DAA520] tracking-widest
                col-span-1 row-start-1 col-start-1 self-start
                w-[8rem] sm:w-[14rem] my-4">
                  LAUNCH A <br>USELESS <br> MACHINE<br> IN THE CLOUD
      </h1>

      <!-- Map at top for dashboard -->
      <%= if @live_action !== :single do %>
        <div class="col-start-1 col-span-4 rounded-lg panel">
          <%= RegionMap.world_map_svg(%{regions: active_regions(@umachines), our_regions: active_regions(@our_mach)}) %>
        </div>
        <!-- Overlay text -->
        <div class="font-mono text-xs text-zinc-200 self-start col-span-4">
          Active regions: <%= Enum.join(active_regions(@umachines), " ") %><br>
          Your Fly.io edge region is <%= CityData.short(@fly_edge_region) %>
        </div>
      <% end %>


      <.live_component
        module={WhereMachinesWeb.MachineLauncher}
        id="machine-launcher"
        variant={@live_action}
        fly_edge_region={@fly_edge_region}
        regions={@regions}
        our_mach_state={@our_mach_state} />

      <!-- Map below button in single mode -->
      <%= if @live_action == :single do %>
        <!-- Overlay text -->
        <div class="font-mono text-xs text-zinc-200 self-start col-span-4 mt-4">
          Your Fly.io edge region is <%= CityData.short(@fly_edge_region) %><br>
          There are Useless Machines in: <%= Enum.join(active_regions(@umachines), " ") %>
        </div>

        <div class="col-start-1 col-span-4 rounded-lg panel">
          <%= RegionMap.world_map_svg(%{regions: active_regions(@umachines), our_regions: active_regions(@our_mach)}) %>
        </div>


      <% end %>

        <DashComponents.machine_table :if={@live_action == :all_regions} live_action={@live_action} machines={@umachines} />

        <div :if={@live_action == :all_regions} class="col-span-1 panel">
          <DashComponents.region_summaries machines={@umachines} />
        </div>

    </div>
    """
  end


  # Handle timer-related messages

  def handle_info({:start_machine_timer, button_id}, socket) do
    # Start the display timer if in single mode
    timer_ref = if socket.assigns.live_action == :single do
      Process.send_after(self(), :timer_tick, 100)
    else
      nil
    end

    {:noreply, assign(socket,
      timer_ref: timer_ref,
      active_timer_button: button_id,
      current_timer_display: "0.0s"
    )}
  end

  def handle_info(:timer_tick, socket) do
    # Get the active button from the component
    send_update(WhereMachinesWeb.MachineLauncher,
      id: "machine-launcher",
      get_active_button: socket.assigns.active_timer_button
    )

    {:noreply, socket}
  end

  def handle_info({:active_button_time, start_time}, socket) when is_number(start_time) do
    elapsed_time = format_elapsed_time(start_time)

    # Schedule next tick
    timer_ref = Process.send_after(self(), :timer_tick, 100)

    {:noreply, assign(socket,
      current_timer_display: elapsed_time,
      timer_ref: timer_ref
    )}
  end

  def handle_info({:active_button_time, nil}, socket) do
    # No active button, stop timer
    if socket.assigns.timer_ref do
      Process.cancel_timer(socket.assigns.timer_ref)
    end

    {:noreply, assign(socket, timer_ref: nil)}
  end

  #####################################################################
  # Handle machine ready message from API controller via PubSub.
  #####################################################################

  def handle_info({:machine_ready, {machine_id, status_map}}, socket) do
    Logger.debug("LiveView got :machine_ready for Machine #{machine_id} in #{status_map.region}")

    our_mach = socket.assigns.our_mach

    if Map.has_key?(our_mach, machine_id) do
      # Stop the display timer
      if socket.assigns.timer_ref do
        Process.cancel_timer(socket.assigns.timer_ref)
      end

      # Tell component to stop its timer and get elapsed time
      send_update(WhereMachinesWeb.MachineLauncher,
        id: "machine-launcher",
        stop_timer_for: machine_id
      )

      if socket.assigns.live_action == :single do
        Logger.info("Redirecting in 500ms")
        Process.send_after(self(), {:redirect_to_machine, machine_id}, 500)
      end
    end

    {:noreply,
      socket
      |> assign(:umachines, new_machines_assign(:update, {machine_id, status_map}, socket))
      |> assign(:our_mach_state, :listening)
      |> assign(timer_ref: nil, active_timer_button: nil)
    }
  end

  # def handle_info({:our_mach_created, {_button_id, machine_id}}, socket) when socket.assigns.live_action == :single do

  #   Logger.info("one-region LiveView received :our_mach_created message")
  #   Logger.info("This means the MachineLauncher live component got a response from flaps and sent a message up to this LiveView.")
  #   Logger.debug("Replacing the :our_mach assign with the specified Machine")
  #   {:noreply, assign(socket, :our_mach, machine_id)}
  # end

  # TODO: clean up old machines in the our_mach assign
  def handle_info({:our_mach_created, {machine_id, status_map}}, socket)  do
    Logger.debug("LiveView received :our_mach_created message for Machine #{machine_id} in #{status_map.region}")
    Logger.debug("This means the MachineLauncher live component got a response from flaps and sent a message up to this LiveView.")
    Logger.debug("Adding the Machine to the our_mach assign")
    {:noreply, assign(socket, our_mach: Map.put(socket.assigns.our_mach, machine_id, status_map))}
  end

  def handle_info({:redirect_to_machine, mach_id}, socket) do
    Logger.debug("About to try redirecting to https://useless-machine.fly.dev/machine?instance=#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine?instance=#{mach_id}")}
    # {:noreply, redirect(socket, external: "/machine/#{mach_id}")}
  end

  #####################################################################
  # Messages from PubSub
  #####################################################################

  def handle_info({:machine_added, {machine_id, status_map}}, socket) do
    Logger.debug("MachineStatusLive: :machine_added for #{machine_id} via PubSub from Launcher component")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_started, machine_id}, socket) do
    Logger.debug("MachineStatusLive: :machine_started for #{machine_id} via PubSub from Launcher component")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, :started}, socket))}
  end

  def handle_info({:machine_stopping, machine_id}, socket) do
    Logger.debug("MachineStatusLive: :machine_stopping for #{machine_id} via PubSub from status controller.")
    {:noreply, socket
      |> assign(:umachines, new_machines_assign(:remove, machine_id, socket))
      |> assign(:our_mach, Map.delete(socket.assigns.our_mach, machine_id))
    }
  end

  def handle_info({:machine_removed, machine_id}, socket) do
    Logger.debug("MachineStatusLive: :machine_removed for #{machine_id} via PubSub from tracker.")
    {:noreply, socket
      |> assign(:umachines, new_machines_assign(:remove, machine_id, socket))
      |> assign(:our_mach, Map.delete(socket.assigns.our_mach, machine_id))
    }
  end

  def handle_info({:replaced_from_api, {machine_id, status_map}}, socket) do
    Logger.debug("MachineStatusLive received :replaced_from_api for #{machine_id}.")

    # If this machine is in our_mach, update it there too
    updated_our_mach = if Map.has_key?(socket.assigns.our_mach, machine_id) do
      Map.put(socket.assigns.our_mach, machine_id, status_map)
    else
      socket.assigns.our_mach
    end

    {:noreply, socket
      |> assign(:umachines, new_machines_assign(:update, {machine_id, status_map}, socket))
      |> assign(:our_mach, updated_our_mach)
    }
  end

  def handle_info({:stop_machine_timer, machine_id}, socket) do
    # Send message to the launcher component to stop the timer
    send_update(WhereMachinesWeb.MachineLauncher,
      id: "machine-launcher",
      stop_timer_for: machine_id
    )
    {:noreply, socket}
  end

  def handle_info({:machine_timer_elapsed, {machine_id, elapsed_str}}, socket) do
    Logger.info("Machine #{machine_id} became ready in #{elapsed_str}")
    # You could store this information or display it if needed
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    Logger.debug("MachineStatusLive ignoring message: #{inspect message}")
    {:noreply, socket}
  end


  # Timer formatting helper
  defp format_elapsed_time(start_time) do
    elapsed_ms = System.system_time(:millisecond) - start_time
    elapsed_s = elapsed_ms / 1000
    :io_lib.format("~.1fs", [elapsed_s]) |> to_string()
  end


  ################################################
  # Helpers to update machines assigns
  ################################################

  # Update only the status to :started for an existing machine
  defp new_machines_assign(:update, {machine_id, :started}, socket) do
    Map.update(socket.assigns.umachines, machine_id, %{status: :started}, fn existing_map ->
      Map.put(existing_map, :status, :started)
    end)
  end

  # Add or update a Machine
  defp new_machines_assign(:update, {machine_id, status_map}, socket) do
    Map.update(socket.assigns.umachines, machine_id, status_map, fn _existing_map -> status_map end)
  end

  # Remove a Machine if it's in the map.
  defp new_machines_assign(:remove, machine_id, socket) do
    # TODO? make machines a keyword list for O(1) lookups (only matters much for huge numbers of machines)
    Map.delete(socket.assigns.umachines, machine_id)
  end

  defp active_regions(machines) do
    for {_key, %{region: region}} <- machines, uniq: true, do: region
  end

  defp regions_for_action(action_atom) do
    case action_atom do
      :single -> [:local]
      :all_regions -> Map.keys(CityData.cities())
      _ -> Logger.error("live_action assign not recognised: #{action_atom}")
    end
  end
end
