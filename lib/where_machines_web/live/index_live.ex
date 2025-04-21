defmodule WhereMachinesWeb.IndexLive do
  use WhereMachinesWeb, :live_view

  require Logger

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    # Subscribe to machine status updates
    # Phoenix.PubSub.subscribe(:where_pubsub, "to:#{System.get_env("FLY_MACHINE_ID")}")
    Phoenix.PubSub.subscribe(:where_pubsub, "machine_updates")

    {:ok, assign(socket,
      fly_edge_region: fly_edge_region,
      our_mach: nil,
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
        WhereMachinesWeb.MachineStatusLive,
        id: "machine-status-live",
        session: %{
          "launcher" => "single",
          "regions" => {[:local]},
          "classes" => "col-span-4 grid grid-cols-4",
          "opts" => {[]}
          },
        container: {:div, class: "col-span-4"}
        )
      %>
    </div>
    """
  end

  #####################################################################
  # Handle machine ready message from API controller via PubSub.
  #####################################################################

  def handle_info({:machine_ready, {machine_id, _status_map}}, socket) do
    Logger.info("IndexLive got :machine_ready from status controller via local PubSub.")
    # If that's our Machine started, redirect the client to the useless machine app
    our_mach = socket.assigns.our_mach
    # TODO: Check buttons assigns for machine id instead (which means storing machine id)
    Logger.info("our_mach: #{our_mach}; machine: #{machine_id}")

    if machine_id == our_mach do
      Process.send_after(self(), {:redirect_to_machine, our_mach}, 100)
    end
    {:noreply, socket}
  end

  def handle_info({:redirect_to_machine, mach_id}, socket) do
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
    # {:noreply, redirect(socket, external: "/machine/#{mach_id}")}
  end

  def handle_info({:our_mach_created, {_button_id, machine_id}}, socket) do
    Logger.info("IndexLive received :our_mach_created message")
    {:noreply, assign(socket, :our_mach, machine_id)}
  end

  def handle_info(message, socket) do
    Logger.debug("IndexLive ignoring message: #{inspect message}")
    {:noreply, socket}
  end

end
