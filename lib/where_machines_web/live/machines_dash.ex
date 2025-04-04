defmodule WhereMachinesWeb.MachinesDash do
  use WhereMachinesWeb, :live_view
  alias WhereMachines.CityData
  alias WhereMachines.MachineTracker
  import WhereMachinesWeb.RegionMap

  require Logger

  @bbox {0, 0, 800, 391}

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    # Subscribe to machine status updates
    this_machine = System.get_env("FLY_MACHINE_ID")
    regions = Map.keys(CityData.cities()) # a list of atoms

    Logger.info("MachinesDash subscribing to :where_pubsub, to:#{this_machine} messages")
    Phoenix.PubSub.subscribe(:where_pubsub, "to:#{this_machine}")
    Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")

    {count, active_regions, region_count} = MachineTracker.region_stats()
    {:ok, assign(socket,
      regions: regions,
      fly_edge_region: fly_edge_region,
      count: count,
      active_regions: active_regions,
      region_count: region_count,
      map_coords: MachineTracker.get_active_region_coords(@bbox),
      umachines: MachineTracker.look_up_all_machines(),
      page_title: "Where Machines"
    )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class="min-h-screen container grid grid-cols-4 content-start gap-8 items-center">

    <div class="col-span-2">Your Fly.io edge region is <%= @fly_edge_region %></div>

      <!-- Map -->
      <div class="col-start-1 col-span-4 panel">
        <%= world_map_svg(%{coords: @map_coords}) %>
        <!-- Overlay text -->
        <div class="text-xs text-zinc-200">
          Active regions: <%= Enum.join(@active_regions, ", ") %>
        </div>
      </div>

      <div class="col-span-1 panel">
        <h3 class="text-lg font-semibold text-yellow-300 mb-2">Active Regions</h3>
        <%= for region <- @active_regions do %>
          <p><%= region %></p>
        <% end %>
      </div>


      <!-- Machine Launcher Component with buttons -->
      <.live_component
        module={WhereMachinesWeb.MachineLauncher}
        id="machine-launcher"
        regions={@regions}
        classes="col-span-4 button-grid"
        btn_class="dash-button"
      ></.live_component>

      <!-- Machine table -->
      <div class="panel col-span-3">
        <h3 class="text-lg font-semibold text-yellow-300 mb-2">Active Machines</h3>
        <div class="w-full overflow-x-auto">
          <table class="min-w-full bg-zinc-800 rounded-lg">
            <thead>
              <tr>
                <th class="py-2 px-4 border-b border-zinc-700 text-left">ID</th>
                <th class="py-2 px-4 border-b border-zinc-700 text-left">Region</th>
                <th class="py-2 px-4 border-b border-zinc-700 text-left">Status</th>
                <th class="py-2 px-4 border-b border-zinc-700 text-left">Last Update</th>
              </tr>
            </thead>
            <tbody>
              <%= for {id, status_map} <- @umachines do %>
                <tr class="hover:bg-zinc-700 transition-colors">
                  <td class="py-2 px-4 border-b border-zinc-700"><%= id %></td>
                  <td class="py-2 px-4 border-b border-zinc-700"><%= status_map.region %></td>
                  <td class="py-2 px-4 border-b border-zinc-700">
                    <span class={status_class(status_map.status)}>
                      <%= status_map.status %>
                    </span>
                  </td>
                  <td class="py-2 px-4 border-b border-zinc-700">
                    <%= format_time(status_map.timestamp) %>
                  </td>
                </tr>
              <% end %>
              <%= if Enum.empty?(@umachines) do %>
                <tr>
                  <td colspan="5" class="py-4 text-center text-zinc-500">No active machines</td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp status_class("started"), do: "px-2 py-1 rounded bg-green-800 text-green-200"
  defp status_class("stopping"), do: "px-2 py-1 rounded bg-red-800 text-red-200"
  defp status_class(_), do: "px-2 py-1 rounded bg-zinc-600 text-zinc-300"

  defp format_time(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, dt, _} -> Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
      _ -> timestamp
    end
  end


  #####################################################################
  # Messages from PubSub
  #####################################################################

  def handle_info({:machine_added, {machine_id, status_map}}, socket) do
    Logger.info("MachinesDash got a :machine_added message from PubSub for #{machine_id}.")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_ready, {machine_id, status_map}}, socket) do
    Logger.info("MachinesDash got a :machine_ready message from PubSub for #{machine_id}.")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_stopping, machine_id}, socket) do
    Logger.info("MachinesDash: :machine_stopping for #{machine_id}. Remove from machines assign.")
    {:noreply, assign(socket, umachines: new_machines_assign(:remove, machine_id, socket))}
  end

  def handle_info({:machine_removed, machine_id}, socket) do
    Logger.info("MachinesDash: :machine_removed for #{machine_id}. Remove from machines assign.")
    {:noreply, assign(socket, umachines: new_machines_assign(:remove, machine_id, socket))}
  end

  def handle_info({:cleanup}, socket) do
    Logger.info("MachinesDash: :cleanup. Update assigns from the table.")
    # Refresh machine data from MachineTracker for map and stats display
    update_assigns_from_table(socket)
  end

  def handle_info({:replaced_from_api,{machine_id, status_map}}, socket) do
    Logger.info("MachinesDash: :replaced_from_api for #{machine_id}.")
    {:noreply, assign(socket, umachines: new_machines_assign(:update,{machine_id, status_map}, socket))}
    # update_assigns_from_table(socket)
  end

  def handle_info(message, socket) do
    Logger.debug("MachinesDash ignoring message: #{inspect message}")
    {:noreply, socket}
  end


  ################################################
  # Helpers to update machines assigns
  ################################################

  # Add or update a Machine
  defp new_machines_assign(:update, {machine_id, status_map}, socket) do
    socket.assigns.umachines |> dbg
    Map.update(socket.assigns.umachines, machine_id, status_map, fn _existing_map -> status_map end)
  end

  # Remove a Machine if it's in the map.
  defp new_machines_assign(:remove, machine_id, socket) do
    # TODO? make machines a keyword list for O(1) lookups (only matters much for huge numbers of machines)
    Map.delete(socket.assigns.umachines, machine_id) |> dbg
  end

  #####################################################################
  # Replace everything with values from ETS
  #####################################################################

  defp update_assigns_from_table(socket) do
    # TODO: less redundant reading of the table
    {count, regions, region_count} = MachineTracker.region_stats()
    coords = MachineTracker.get_active_region_coords(@bbox)
    {:noreply, assign(socket,
      umachines: MachineTracker.look_up_all_machines(),
      active_regions: regions,
      machine_count: count,
      region_count: region_count,
      map_coords: coords
    )}
  end

end
