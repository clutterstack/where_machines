defmodule WhereMachinesWeb.WhereLive do
  use WhereMachinesWeb, :live_view

  alias WhereMachines.{CityData, MachineTracker}
  alias WhereMachinesWeb.{RegionMap, DashComponents}

  require Logger

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    if connected?(socket) do
      # Subscribe to machine status updates
      Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")
    end

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
      page_title: "Where Machines"
    )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class="min-h-screen grid grid-cols-4 gap-x-8 w-full content-start">

        <!-- Map -->
        <div class="col-start-1 col-span-4 rounded-lg panel">
          <%= RegionMap.world_map_svg(%{regions: active_regions(@umachines), our_regions: active_regions(@our_mach)}) %>
        </div>

         <!-- Overlay text -->
          <div class="font-mono text-xs text-zinc-200 self-start col-span-4">
            Active regions: <%= Enum.join(active_regions(@umachines), " ") %><br>
            Your Fly.io edge region is <%= @fly_edge_region %>

          </div>

        <.live_component
          module={WhereMachinesWeb.MachineLauncher}
          id="machine-launcher"
          variant={@live_action}
          fly_edge_region={@fly_edge_region}
          regions={@regions}
          our_mach_state={@our_mach_state} />

        <DashComponents.machine_table live_action={@live_action} machines={@umachines} />

        <div :if={@live_action == :all_regions} class="col-span-1 panel">
          <DashComponents.region_summaries machines={@umachines} />
        </div>

    </div>
    """
  end

  #####################################################################
  # Handle machine ready message from API controller via PubSub.
  #####################################################################

  def handle_info({:machine_ready, {machine_id, status_map}}, socket) do
    Logger.info("LiveView got :machine_ready from status controller via local PubSub.")

    # The single-button version of the LiveView redirects to the new Machine, after making sure it's ours.
    # This is belt and braces, since the Useless Machine calls its requesting node back directly when it's ready
    if socket.assigns.live_action == :single do
      Logger.info("Checking if it's our Machine.")
      our_mach = socket.assigns.our_mach

      Logger.debug("our_mach: #{inspect our_mach}; machine: #{machine_id}")

      if Map.has_key?(our_mach, machine_id) do
        Logger.info("Redirecting in 500ms")
        Process.send_after(self(), {:redirect_to_machine, machine_id}, 500)
      end
    end

    {:noreply,
      socket
      |> assign(:umachines, new_machines_assign(:update, {machine_id, status_map}, socket))
      |> assign(:our_mach_state, :listening)
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
    Logger.info("LiveView received :our_mach_created message for Machine #{machine_id} in #{status_map.region}")
    Logger.info("This means the MachineLauncher live component got a response from flaps and sent a message up to this LiveView.")
    Logger.debug("Adding the Machine to the our_mach assign")
    {:noreply, assign(socket, our_mach: Map.put(socket.assigns.our_mach, machine_id, status_map))}
  end

  def handle_info({:redirect_to_machine, mach_id}, socket) do
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
    # {:noreply, redirect(socket, external: "/machine/#{mach_id}")}
  end

  #####################################################################
  # Messages from PubSub
  #####################################################################

  def handle_info({:machine_added, {machine_id, status_map}}, socket) do
    Logger.info("MachineStatusLive: :machine_added for #{machine_id} via PubSub from Launcher component")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_started, {machine_id, status_map}}, socket) do
    Logger.info("MachineStatusLive: :machine_started for #{machine_id} via PubSub from Launcher component")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_stopping, machine_id}, socket) do
    Logger.info("MachineStatusLive: :machine_stopping for #{machine_id} via PubSub from status controller.")
    {:noreply, assign(socket, umachines: new_machines_assign(:remove, machine_id, socket))}
  end

  def handle_info({:machine_removed, machine_id}, socket) do
    Logger.info("MachineStatusLive: :machine_removed for #{machine_id} via PubSub from tracker.")
    {:noreply, assign(socket, umachines: new_machines_assign(:remove, machine_id, socket))}
  end

  def handle_info({:replaced_from_api,{machine_id, status_map}}, socket) do
    Logger.info("MachineStatusLive received :replaced_from_api for #{machine_id}.")
    {:noreply, assign(socket, umachines: new_machines_assign(:update,{machine_id, status_map}, socket))}
    # update_assigns_from_table(socket)
  end

  def handle_info(message, socket) do
    Logger.debug("MachineStatusLive ignoring message: #{inspect message}")
    {:noreply, socket}
  end

  ################################################
  # Helpers to update machines assigns
  ################################################

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
