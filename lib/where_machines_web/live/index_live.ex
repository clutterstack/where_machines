defmodule WhereMachinesWeb.IndexLive do
  use WhereMachinesWeb, :live_view
  alias Phoenix.LiveView.AsyncResult
  import WhereMachinesWeb.RegionMap
  alias WhereMachines.MachineTracker
  import WhereMachines.MachineLauncher
  alias WhereMachines.MachinesDash


  require Logger

  @bbox {0, 0, 800, 391}

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    # Subscribe to machine status updates
    this_machine = System.get_env("FLY_MACHINE_ID")
    Logger.info("IndexLive subscribing to :where_pubsub, to:#{this_machine} messages")
    Phoenix.PubSub.subscribe(:where_pubsub, "to:#{this_machine}")


    {count, regions, region_count} = MachineTracker.region_stats()

    coords = MachineTracker.get_active_region_coords(@bbox)
    machines = MachineTracker.look_up_all_machines()
    {:ok, assign(socket,
      layout: false,
      fly_edge_region: fly_edge_region,
      active_regions: regions,
      machine_count: count,
      region_count: region_count, # we don't actually use this rn
      map_coords: coords,
      create_async: AsyncResult.ok(:idle),
      button_status: AsyncResult.ok(:idle),  # :idle, :starting, :success, :error
      button_text: "Create New Machine",
      machines: machines,
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
      <div class="col-start-1 col-span-4 panel relative">
        <%= world_map_svg(%{coords: @map_coords}) %>
        <!-- Overlay text -->
        <div class="text-xs text-zinc-200">
          Active regions: <%= Enum.join(@active_regions, ", ") %>
        </div>
        <!-- Map credit -->
        <div class="absolute bottom-2 right-4 text-[10px]">
          Made with Natural Earth.
        </div>
      </div>

      <div class="col-span-1 panel">
        <h3 class="text-lg font-semibold text-yellow-300 mb-2">Active Regions</h3>
        <%= for region <- @active_regions do %>
          <p><%= region %></p>
        <% end %>
      </div>



      <!-- Create Machine Button -->
      <div class="panel col-span-3">
        <div>Push button to create your Useless Machine in the cloud</div>
        <div class="text-2xl">START</div>

          <!-- Outer circle -->
          <div class="relative rounded-full border-2 border-zinc-700 w-20 h-20 flex justify-center items-center">

          <!-- Button -->
          <button
            id="button-nearest"
            phx-click={@button_status === :idle && "create_machine" || nil}
            phx-value-region=""
            phx-value-id="nearest"
            disabled={@button_status !== :idle}
            class={["absolute
                    w-16 h-16 rounded-full
                    border border-[#DAA520]
                    text-transparent
                    cursor-pointer z-10
                    shadow-lg
                    hover:shadow-xl
                    active:scale-95
                    transition-all duration-300",
                    button_class(@button_status)
                    ]}>
            <%= @button_text %>
          </button>
          </div>
        </div>

        <div class="panel col-start-2">
        <%= if @create_async do %>
          <.async_result :let={result} assign={@create_async}>
            <:loading>Waiting for API response.</:loading>
            <:failed :let={reason}>{reason}</:failed>
            <div :if={result.status_map} >Machine created in {result.status_map.region}</div>
            <div>{result.machine_id}</div>
          </.async_result>
        <% else %>
          <div>Push button to create your useless Machine</div>
      <% end %>
      </div>

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
              <%= for machine <- @machines do %>
                <tr class="hover:bg-zinc-700 transition-colors">
                  <td class="py-2 px-4 border-b border-zinc-700"><%= machine.id %></td>
                  <td class="py-2 px-4 border-b border-zinc-700"><%= machine.region %></td>
                  <td class="py-2 px-4 border-b border-zinc-700">
                    <span class={status_class(machine.status)}>
                      <%= machine.status %>
                    </span>
                  </td>
                  <td class="py-2 px-4 border-b border-zinc-700">
                    <%= format_time(machine.timestamp) %>
                  </td>
                </tr>
              <% end %>
              <%= if Enum.empty?(@machines) do %>
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

  #  WhereMachinesWeb.IndexLive.button_class(%Phoenix.LiveView.AsyncResult{ok?: true, loading: nil, failed: nil, result: :idle})
  defp button_class(%{result: :idle}), do: "btn bg-stone-400"
  defp button_class(:starting), do: "btn bg-amber-500 from-yellow-300 to-yellow-50"
  defp button_class(:success), do: "btn bg-green-500"
  defp button_class(:error), do: "btn bg-red-500"

  def handle_event("create_machine", %{"region" => region, "id" => button_id}, socket) do
    {:noreply,
     socket
     |> assign(create_async: AsyncResult.loading())
     |> start_async(:create_machine_task, fn -> maybe_spawn_useless_machine(button_id, region) end)
    }
  end

  # %Req.Response{status: 200, headers: %{"content-type" => ["application/json; charset=utf-8"], "date" => ["Tue, 01 Apr 2025 19:49:21 GMT"], "fly-request-id" => ["01JQSECXHAJR7ZPGFRTQW5EK95-yyz"], "fly-span-id" => ["158e9e36260ca7b1"], "fly-trace-id" => ["db0676a0b790c21315850ab6d6b07efd"], "server" => ["Fly/60c773e9c (2025-04-01)"], "transfer-encoding" => ["chunked"], "via" => ["1.1 fly.io"], "x-envoy-upstream-service-time" => ["16901"]}, body: %{"config" => %{"auto_destroy" => true, (etc.)
  def handle_async(:create_machine_task, {:ok, {:ok, %{requestor_id: _requestor_id, machine_id: machine_id, status_map: status_map} = response}}, socket) do
    Logger.info("Machine created successfully.")
    Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_added, %{machine_id: machine_id, status_map: status_map}})
    {:noreply, assign(socket,
      button_status: :success,
      button_text: "Machine created",
      create_async: AsyncResult.ok(response)
    )}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{requestor_id: _requestor_id, stuff: %Req.TransportError{reason: :timeout}}}}, socket) do
    Logger.error("Machine creation request timed out")
    %{create_async: create_async} = socket.assigns
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Request timed out",
      create_async: AsyncResult.failed(create_async, "Timed out"))}
  end

  def handle_async(:create_machine_task, {:error, %{reason: :capacity, message: message}}, socket) do
    Logger.info("No capacity: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{message: message}}}, socket) do
    %{create_async: create_async} = socket.assigns
    Logger.error("Machine creation failed: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_async: AsyncResult.failed(create_async, message))}
  end

  def handle_async(:create_machine_task, {:ok, {:error, message}}, socket) do
    %{create_async: create_async} = socket.assigns
    Logger.info("Machine creation failed: #{message}")
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_async: AsyncResult.failed(create_async, message))}
  end

  def handle_async(:create_machine_task, {:exit, %{message: message}}, socket) do
    Logger.error("Machine creation task crashed with message: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_async(:create_machine_task, {:exit, something_else}, socket) do
    Logger.error("Machine creation task crashed: #{inspect something_else}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_info(:redirect_to_machine, socket) do
    mach_id = socket.assigns.create_async.result.body["id"]
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
    # {:noreply, redirect(socket, external: "/machine/#{mach_id}")}

  end

  def handle_info(:reset_button, socket) do
    Logger.info("reset_button called")
    {:noreply, assign(socket, button_status: :idle, button_text: "Create Machine", create_async: nil)}
  end

    ########################
    # Messages from PubSub #
    ########################

  # :machine_ready
  # :replaced_from_api
  # :machine_added
  # :cleanup

  def handle_info({:machine_ready, %{machine_id: machine_id, status_map: status_map}}, socket) do
    Logger.info("IndexLive got a :machine_ready message from PubSub for #{machine_id}}.")
    # If that's our Machine started, redirect the client to the useless machine app
      our_mach = socket.assigns.create_async.result.body["id"]
      Logger.info("our_mach: #{our_mach}; machine: #{machine_id}")
      if machine_id == our_mach do
        Logger.info("That's our Machine. Update assigns from the table and redirect.")
        Process.send_after(self(), :redirect_to_machine, 100)
      else
        Logger.info("Not our Machine. Update assigns but don't redirect.")
      end
      {:noreply, assign(socket, machines: MachinesDash.new_machines_assign(%{machine_id: machine_id, status_map: status_map}, socket))}

  end

  def handle_info({:machine_ready, %{machine_id: machine_id, status_map: status_map}}, socket) do
    Logger.info("IndexLive got a :machine_ready message from PubSub for #{machine_id}}.")
    # If that's our Machine started, redirect the client to the useless machine app
      our_mach = socket.assigns.create_async.result.body["id"]
      Logger.info("our_mach: #{our_mach}; machine: #{machine_id}")
      if machine_id == our_mach do
        Logger.info("That's our Machine. Update assigns from the table and redirect.")
        Process.send_after(self(), :redirect_to_machine, 100)
      else
        Logger.info("Not our Machine. Update assigns but don't redirect.")
      end
      {:noreply, assign(socket, machines: MachinesDash.new_machines_assign(%{machine_id: machine_id, status_map: status_map}, socket))}

  end

  def handle_info({:table_updated, message}, socket) do
    Logger.info("IndexLive got a :table_updated message from PubSub: #{inspect message}. Updating assigns from the table.")
    update_assigns_from_table(socket)
  end

  def handle_info({:machine_stopping, machine_id}, socket) do
    Logger.info("IndexLive: :machine_stopping for #{machine_id}. Update assigns from the table.")
    # Refresh machine data from MachineTracker for map and stats display
    update_assigns_from_table(socket)
  end

  def handle_info({:cleanup}, socket) do
    Logger.info("IndexLive: :cleanup. Update assigns from the table.")
    # Refresh machine data from MachineTracker for map and stats display
    update_assigns_from_table(socket)
  end

  def handle_info(message, socket) do
    Logger.info("IndexLive received unknown message: #{inspect message}")
    {:noreply, socket}
  end

  defp update_assigns_from_table(socket) do
    {count, regions, region_count} = MachineTracker.region_stats()
    coords = MachineTracker.get_active_region_coords(@bbox)
    {:noreply, assign(socket,
      machines: MachineTracker.look_up_all_machines(),
      active_regions: regions,
      machine_count: count,
      region_count: region_count,
      map_coords: coords
    )}
  end

end
