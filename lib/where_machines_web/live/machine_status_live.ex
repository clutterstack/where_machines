defmodule WhereMachinesWeb.MachineStatusLive do
  use WhereMachinesWeb, :live_view
  alias WhereMachines.CityData
  alias WhereMachines.MachineTracker
  import WhereMachinesWeb.RegionMap

  require Logger

  @bbox {0, 0, 800, 391}

  def mount(_params, session, socket) do
    # Subscribe to machine status updates
    Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")

    # Populate Machines list from the ETS table
    initial_machines = MachineTracker.look_up_all_machines()

    {:ok, assign(socket,
      classes: session["classes"],
      opts: session["opts"],
      umachines: initial_machines
    )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class={@classes}>
    <!-- Map -->
    <div class="col-start-1 col-span-4 panel">
      <%= world_map_svg(%{coords: get_active_region_coords(active_regions(@umachines))}) %>
      <!-- Overlay text -->
      <div class="text-xs text-zinc-200">
        Active regions: <%= Enum.join(active_regions(@umachines), " ") %>
      </div>
    </div>

    <div class="col-span-1 panel">
      <h3 class="text-lg font-semibold text-yellow-300 mb-2">Active Regions</h3>
      <%= for {region, count} <- region_stats(@umachines) do %>
        <p>{region}: {count}</p>
      <% end %>
    </div>

    <!-- Machine table -->
    <div class="panel col-span-3">
      <h3 class="text-lg font-semibold text-yellow-300 mb-2">Machines (Total {Enum.count(@umachines)})</h3>
      <div class="w-full overflow-x-auto text-sm">
        <table class="min-w-full">
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
    Logger.info("MachineStatusLive: :machine_added for #{machine_id} via PubSub from Launcher component")
    {:noreply, assign(socket, umachines: new_machines_assign(:update, {machine_id, status_map}, socket))}
  end

  def handle_info({:machine_ready, {machine_id, status_map}}, socket) do
    Logger.info("MachineStatusLive: :machine_ready for #{machine_id} via local PubSub from status controller.")
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

  @doc """
  Number of Machines by region
  %{"ams" => 1}
  """
  def region_stats(machines) do
    machines
    |> Enum.reduce(%{}, fn {_key, %{region: region}}, acc ->
      Map.update(acc, region, 1, &(&1 + 1))
    end)
  end

  def active_regions(machines) do
    for {_key, %{region: region}} <- machines, uniq: true, do: region
  end

end
