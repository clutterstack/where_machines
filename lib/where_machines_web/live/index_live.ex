defmodule WhereMachinesWeb.IndexLive do
  use WhereMachinesWeb, :live_view
  alias Phoenix.LiveView.AsyncResult
  import WhereMachinesWeb.RegionMap
  alias WhereMachines.CityData
  # NEW: Added MachineTracker alias
  alias WhereMachines.MachineTracker

  require Logger

  @mach_params WhereMachines.MachineParams.useless_params()
  @app_name "useless-machine"
  @mach_limit 3

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    # NEW: Subscribe to machine status updates
    Phoenix.PubSub.subscribe(:where_pubsub, "machine_status")

    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))

    # CHANGED: Use MachineTracker instead of check_machines(client)
    {count, regions, region_map} = MachineTracker.region_stats()

    # NEW: Get map coordinates for active regions
    coords = MachineTracker.get_active_region_coords({0, 0, 800, 391})

    {:ok, assign(socket,
      layout: false,
      fly_edge_region: fly_edge_region,
      client: client,
      active_regions: regions,
      machine_count: count,
      # NEW: Store region map
      region_map: region_map,
      # NEW: Store map coordinates
      map_coords: coords,
      create_status: nil,
      button_status: :idle,  # :idle, :starting, :success, :error
      button_text: "Create New Machine",
      # CHANGED: Get machines from MachineTracker
      machines: MachineTracker.get_all_machines(),
      page_title: "Where Machines"
    )}
  end

  # bg-[1200px_auto]
  # bg-[position:var(--bg-pos)]
  # border border-yellow-200
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-[url:var(--bg-image)] bg-no-repeat bg-cover"
      style={"--bg-image: url(#{~p'/images/curves_bigger.svg'}); --bg-pos: right top -200px;" }
    >
        <div class="min-h-screen container grid grid-cols-4 content-start gap-8 max-w-3xl mx-auto items-center">

        <header class="py-2 col-span-3 col-start-1">
          <h1 class="text-4xl font-mono font-bold text-[#DAA520] tracking-widest mb-2">WHERE MACHINES</h1>
          <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-200">
      <a href="https://bsky.app/profile/clutterstack.com" class="hover:text-zinc-700">
        Bluesky
      </a>
      <a href="https://github.com/clutterstack" class="hover:text-zinc-700">
        GitHub
      </a>
    </div>
          <p class="text-zinc-400">Create a Useless Machine in the cloud</p>
        </header>

        <!-- Map -->
        <div class="col-start-1 col-span-3 panel">
            <!-- CHANGED: Use map_coords from MachineTracker -->
            <%= world_map_svg(%{coords: @map_coords}) %>

            <!-- Overlay text -->
            <div class="text-xs text-zinc-200">
              <!-- CHANGED: Join active regions into a string -->
              Active regions: <%= Enum.join(@active_regions, ", ") %>
            </div>
        </div>

        <!-- Create Machine Button -->
        <div class="panel col-start-2">
          <div>Your Fly.io edge region is <%= @fly_edge_region %></div>
          <div class="text-2xl">START</div>

            <!-- Outer circle -->
            <div class="relative rounded-full border-2 border-zinc-700 w-20 h-20 flex justify-center items-center">

            <!-- Button -->
            <button
              phx-click={@button_status === :idle && "create_machine" || nil}
              disabled={@button_status !== :idle}
              class={["absolute
                      w-16 h-16 rounded-full
                      border-1 border-[#DAA520]
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
        <%= if @create_status do %>
          <.async_result :let={result} assign={@create_status}>
            <:loading>Waiting for API response.</:loading>
            <:failed :let={reason}>{reason}</:failed>
            <div>Machine created in {result.body["region"]}</div>
            <div>{result.body["id"]}</div>
            <div>{result.body["private_ip"]}</div>
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
                <th class="py-2 px-4 border-b border-zinc-700 text-left">Actions</th>
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
                  <td class="py-2 px-4 border-b border-zinc-700">
                    <button
                      phx-click="view_machine"
                      phx-value-id={machine.id}
                      class="text-yellow-400 hover:text-yellow-200">
                      View
                    </button>
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
    </div>
    """
  end

  # NEW: Helper for status styling
  defp status_class("started"), do: "px-2 py-1 rounded bg-green-800 text-green-200"
  defp status_class("stopping"), do: "px-2 py-1 rounded bg-red-800 text-red-200"
  defp status_class(_), do: "px-2 py-1 rounded bg-zinc-600 text-zinc-300"

  # NEW: Format timestamp helper
  defp format_time(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, dt, _} -> Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
      _ -> timestamp
    end
  end

  defp button_class(:idle), do: "btn bg-stone-400"
  defp button_class(:starting), do: "btn bg-amber-500 from-yellow-300 to-yellow-50"
  defp button_class(:success), do: "btn bg-green-500"
  defp button_class(:error), do: "btn bg-red-500"

  def handle_event("create_machine", _params, socket) do
    client_assign = socket.assigns.client
    {:noreply,
     socket
     |> assign(button_status: :starting, button_text: "Creating Machine", create_status: AsyncResult.loading())
     |> start_async(:create_machine_task, fn -> maybe_spawn_useless_machine(client_assign) end)
    }
  end

  def handle_event("view_machine", %{"id" => machine_id}, socket) do
    Logger.info("View machine details: #{machine_id}")
    {:noreply, socket}
  end

  def handle_async(:create_machine_task, {:ok, {:ok, result}}, socket) do
    Logger.info("Machine created successfully")
    Process.send_after(self(), :redirect_to_machine, 3000)

    # CHANGED: Removed adding machine to socket
    {:noreply, assign(socket,
      button_status: :success,
      button_text: "Machine created",
      create_status: AsyncResult.ok(result)
    )}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %Req.TransportError{reason: :timeout}}}, socket) do
    Logger.error("Machine creation request timed out")
    %{create_status: create_status} = socket.assigns
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Request timed out",
      create_status: AsyncResult.failed(create_status, "Timed out"))}
  end

  def handle_async(:create_machine_task, {:error, %{reason: :capacity, message: message}}, socket) do
    Logger.info("No capacity: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{message: message}}}, socket) do
    %{create_status: create_status} = socket.assigns
    Logger.error("Machine creation failed: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_status: AsyncResult.failed(create_status, message))}
  end

  def handle_async(:create_machine_task, {:ok, {:error, message}}, socket) do
    %{create_status: create_status} = socket.assigns
    Logger.info("Machine creation failed: #{message}")
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_status: AsyncResult.failed(create_status, message))}
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
    mach_id = socket.assigns.create_status.result.body["id"]
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
  end

  def handle_info(:machines_synced, socket) do
    mach_id = socket.assigns.create_status.result.body["id"]
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
  end


  # REMOVED: handle_info(:replay_to_machine, socket) - no longer needed
  # REMOVED: handle_info(:redirect_w_req_header, socket) - no longer needed

  def handle_info(:reset_button, socket) do
    Logger.info("reset_button called")
    {:noreply, assign(socket, button_status: :idle, button_text: "Create Machine", create_status: nil)}
  end

  # REMOVED: handle_info({:data, payload}, socket) - no longer needed with MachineTracker

  # NEW: Handle machine status updates from PubSub
  def handle_info({:machine_status_changed, _machine_id, _status}, socket) do
    # Refresh machine data from MachineTracker
    {count, regions, region_map} = MachineTracker.region_stats()
    coords = MachineTracker.get_active_region_coords({0, 0, 800, 391})

    {:noreply, assign(socket,
      machines: MachineTracker.get_all_machines(),
      active_regions: regions,
      machine_count: count,
      region_map: region_map,
      map_coords: coords
    )}
  end

  def handle_info(message, socket) do
    Logger.info("IndexLive received unknown message: #{inspect message}")
    {:noreply, socket}
  end

  def maybe_spawn_useless_machine(client) do
    # First check tracker (fast)
    {count, _regions, _} = MachineTracker.region_stats()

    if count < @mach_limit do
      # If tracker says we have capacity, verify with API (accurate)
      case Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
        {:ok, api_machines} ->
          # Count running machines from API
          running_count = Enum.count(api_machines, fn m ->
            m["state"] == "started" || m["state"] == "running"
          end)

          if running_count < @mach_limit do
            Logger.info("API verification confirms capacity; creating a new Machine")
            Clutterfly.FlyAPI.create_machine(client, @app_name, @mach_params)
          else
            Logger.info("API check shows no capacity; not creating a new Machine")
            {:error, %{reason: :capacity, message: "No capacity according to API check"}}
          end

        {:error, reason} ->
          # API check failed, fall back to tracker data
          Logger.warning("API check failed: #{inspect(reason)}. Using tracker data.")
          if count < @mach_limit do
            Logger.info("Capacity OK according to tracker; creating a new Machine")
            Clutterfly.FlyAPI.create_machine(client, @app_name, @mach_params)
          else
            {:error, %{reason: :capacity, message: "Reached capacity; try again later."}}
          end
      end
    else
      Logger.info("Machine limit reached; not creating a new one.")
      {:error, %{reason: :capacity, message: "Reached capacity; try again later."}}
    end
  end
end
