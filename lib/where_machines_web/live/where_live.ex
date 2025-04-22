defmodule WhereMachinesWeb.WhereLive do
  use WhereMachinesWeb, :live_view

  alias WhereMachines.{CityData, MachineTracker}
  alias WhereMachinesWeb.{RegionMap, DashComponents, Launchers}

  @bbox {0, 0, 800, 391}

  require Logger

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do

    if connected?(socket) do
      # Subscribe to machine status updates
      Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")
       # Populate Machines list from the ETS table
    end

    initial_machines = MachineTracker.look_up_all_machines()
    live_action = socket.assigns.live_action

    {:ok, assign(socket,
      fly_edge_region: fly_edge_region,
      regions: regions_for_action(live_action),
      umachines: initial_machines,
      our_mach: our_mach_empty(live_action),
      page_title: "Where Machines",
      classes: "col-span-4 grid grid-cols-4" # TODO: Make this depend on @live_action
    )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class="min-h-screen container grid grid-cols-4 content-start gap-8 items-center">

      <div class="col-span-2">Your Fly.io edge region is <%= @fly_edge_region %></div>

          <div class={@classes}>
          <!-- Map -->
          <div class="col-start-1 col-span-4 panel">
            <%= RegionMap.world_map_svg(%{coords: get_active_region_coords(active_regions(@umachines))}) %>
            <!-- Overlay text -->
            <div class="text-xs text-zinc-200">
              Active regions: <%= Enum.join(active_regions(@umachines), " ") %>
            </div>
          </div>

          <Launchers.launcher variant={@live_action} regions={@regions} />

          <DashComponents.machine_table live_action={@live_action} machines={@umachines} />

          <div :if={@live_action == :all_regions} class="col-span-1 panel">
            <DashComponents.region_summaries machines={@umachines} />
          </div>
        </div>
    </div>
    """
  end

  #####################################################################
  # Handle machine ready message from API controller via PubSub.
  #####################################################################

  def handle_info({:machine_ready, {machine_id, status_map}}, socket) do
    Logger.info("LiveView got :machine_ready from status controller via local PubSub.")
    # We're only set up to use this info in the single-button version of the LiveView
    if socket.assigns.live_action == :single do
      Logger.info("Checking if it's our Machine.")
      # If that's our Machine started, redirect the client to the useless machine app
      our_mach = socket.assigns.our_mach
      # TODO: Check buttons assigns for machine id instead (which means storing machine id)
      Logger.info("our_mach: #{our_mach}; machine: #{machine_id}")

      if machine_id == our_mach do
        Logger.info("Redirecting in 100ms")
        Process.send_after(self(), {:redirect_to_machine, our_mach}, 100)
      end
    end
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:our_mach_created, {_button_id, machine_id}}, socket) when socket.assigns.live_action == :single do

    Logger.info("one-region LiveView received :our_mach_created message")
    Logger.info("This means the MachineLauncher live component got a response from flaps and sent a message up to this LiveView.")
    Logger.debug("Replacing the :our_mach assign with the specified Machine")
    {:noreply, assign(socket, :our_mach, machine_id)}
  end

  def handle_info({:our_mach_created, {button_id, machine_id}}, socket)  do
    Logger.info("all_regions LiveView received :our_mach_created message")
    Logger.info("This means the MachineLauncher live component got a response from flaps and sent a message up to this LiveView.")
    Logger.debug("Adding the Machine to the our_mach assign")
    {:noreply, assign(socket, our_mach: Map.put(socket.assigns.our_mach, button_id, machine_id))}
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

  @doc """
  Get coordinates for active regions to display on the map
  """
  def get_active_region_coords(regions) do
    # Convert region codes to coordinates for the map
    regions
    |> Enum.map(fn region -> CityData.city_to_svg(region, @bbox) end)
  end



  def active_regions(machines) do
    for {_key, %{region: region}} <- machines, uniq: true, do: region
  end

  defp regions_for_action(action_atom) do
    case action_atom do
      :single -> [:local]
      :all_regions -> Map.keys(CityData.cities())
      _ -> Logger.error("live_action assign not recognised: #{action_atom}")
    end
  end

  defp our_mach_empty(action_atom) do
    case action_atom do
      :single -> nil
      :all_regions -> %{}
    end
  end

end
