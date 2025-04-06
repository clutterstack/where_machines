defmodule WhereMachinesWeb.MachinesDash do
  use WhereMachinesWeb, :live_view
  alias WhereMachines.CityData
  alias WhereMachinesWeb.MachineStatusLive
  alias WhereMachinesWeb.MachineLauncher

  require Logger

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    {:ok, assign(socket,
      regions: Map.keys(CityData.cities()), # a list of atoms
      fly_edge_region: fly_edge_region,
      our_machines: %{},
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

      <!-- MachineStatusLive child LV to watch machines -->
      <%= live_render(@socket,
        MachineStatusLive,
        id: "machine-status-live",
        session: %{
          "classes" => "col-span-4 grid grid-cols-4",
          "opts" => {[]}
          },
          container: {:div, class: "col-span-4"}
        )
      %>

      <!-- Machine Launcher Component with buttons -->
      <.live_component
        module={MachineLauncher}
        id="machine-launcher"
        regions={@regions}
        classes="col-span-4 button-grid"
        btn_class="dash-button"
      ></.live_component>

    </div>
    """
  end

  def handle_info({:our_mach_created, {button_id, machine_id}}, socket) do
    {:noreply, assign(socket, our_machines: Map.put(socket.assigns.our_machines, button_id, machine_id))}
  end

  # Need this because the MachineStatusLive LiveComponent subscribed us
  def handle_info(message, socket) do
    Logger.debug("MachinesDash ignoring message: #{inspect message}")
    {:noreply, socket}
  end

end
