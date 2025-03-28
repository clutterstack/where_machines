defmodule WhereMachinesWeb.IndexLive do
  use WhereMachinesWeb, :live_view
  alias Phoenix.LiveView.AsyncResult
  import WhereMachinesWeb.RegionMap
  alias WhereMachines.CityData

  require Logger

  @mach_params WhereMachines.MachineParams.useless_params()

  @app_name "useless-machine"

  @mach_limit 3

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
    {count, regions} = check_machines(client)
    {:ok, assign(socket,
      layout: false,
      fly_edge_region: fly_edge_region,
      client: client,
      active_regions: regions,
      machine_count: count,
      create_status: nil,
      button_status: :idle,  # :idle, :starting, :success, :error
      button_text: "Create New Machine",
      machines: [],
      page_title: "Where Machines"
    ), temporary_assigns: [machines: []]}
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

            <!-- World Map SVG with machine indicators -->
            <%= world_map_svg(%{coords: active_regions()}) %>

            <!-- Overlay text -->
            <div class=" text-xs text-zinc-200">
              Active regions: YYZ, LAX, AMS, SYD
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


      </div>
    </div>
    """
  end

  def active_regions() do
    bbox = {0, 0, 800, 391}
    [
    CityData.city_to_svg(:YYZ, bbox),
    CityData.latlong_to_svg({0,0}, bbox),
    CityData.city_to_svg(:SYD, bbox)
    ]
  end

  defp button_class(:idle), do: "btn bg-stone-400"
  defp button_class(:starting), do: "btn bg-amber-500 from-yellow-300 to-yellow-50"
  defp button_class(:success), do: "btn bg-green-500"
  defp button_class(:error), do: "btn bg-red-500"


  # Format datetime helper
  defp format_datetime(datetime) do
    datetime |> Calendar.strftime("%Y-%m-%d %H:%M")
  end

  def handle_event("create_machine", _params, socket) do
    # Logger.info("received create_machine event for app_name #{@app_name}")
    client_assign = socket.assigns.client
    {:noreply,
     socket
     |> assign(button_status: :starting, button_text: "Creating Machine", create_status: AsyncResult.loading())
     #the :create_status assign is now an AsyncResult struct with loading: true
     |> start_async(:create_machine_task, fn -> maybe_spawn_useless_machine(client_assign) end)
    }
  end


  def handle_event("view_machine", %{"id" => machine_id}, socket) do
    # In a real app, this would redirect to a detail page or open a modal
    Logger.info("View machine details: #{machine_id}")
    {:noreply, socket}
  end


  def handle_async(:create_machine_task, {:ok, {:ok, result}}, socket) do
    # Success: Machine created
    Logger.info("Machine created successfully")
    Process.send_after(self(), :redirect_to_machine, 3000)

    new_machine = %{
      id: result.body["id"],
      region: result.body["region"],
      status: "starting",
      created_at: DateTime.utc_now()
    }

    {:noreply, assign(socket,
      button_status: :success,
      button_text: "Machine created",
      create_status: AsyncResult.ok(result),
      machines: [new_machine | socket.assigns.machines]
    )}
  end


  # def handle_async(:create_machine_task, {:ok, {:ok, result}}, socket) do
  #   # Success: Machine created
  #   Logger.info("Returned success")
  #   Process.send_after(self(), :redirect_to_machine, 3000)
  #   {:noreply, assign(socket,
  #     button_status: :success,
  #     button_text: "Machine created",
  #     create_status: AsyncResult.ok(result))}
  # end

  def handle_async(:create_machine_task, {:ok, {:error, %Req.TransportError{reason: :timeout}}}, socket) do
    # Timeout response (408)
    Logger.error("Machine creation request timed out")
    %{create_status: create_status} = socket.assigns
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Request timed out",
      create_status: AsyncResult.failed(create_status, "Timed out"))}
  end

  def handle_async(:create_machine_task, {:error, %{reason: :capacity, message: message}}, socket) do
    # App already has @mach_limit Machines
    Logger.info("No capacity: #{message}")
    # Reset the button status after 3 seconds
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{message: message}}}, socket) do
    # Other error
    Logger.info("matched handle_async(:create_machine_task, {:ok, {:error, %{message: message}}}, socket)")
    %{create_status: create_status} = socket.assigns
    Logger.error("Machine creation failed: #{message}")
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_status: AsyncResult.failed(create_status, message))}
  end

  def handle_async(:create_machine_task, {:ok, {:error, message}}, socket) do
    # Other error
    Logger.info("matched handle_async(:create_machine_task, {:ok, {:error, %{message: message}}}, socket)")
    %{create_status: create_status} = socket.assigns
    Logger.info("Machine creation failed: #{message}")
    {:noreply, assign(socket,
      button_status: :error,
      button_text: "Machine creation failed",
      create_status: AsyncResult.failed(create_status, message))}
  end

  def handle_async(:create_machine_task, {:exit, %{message: message}}, socket) do
    # Task crashed
    Logger.error("Machine creation task crashed with :message #{message}")
    # Reset the button status after 3 seconds
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_async(:create_machine_task, {:exit, something_else}, socket) do
    # Task crashed
    Logger.error("Machine creation task crashed: #{inspect something_else}")
    # Reset the button status after 3 seconds
    Process.send_after(self(), :reset_button, 3000)
    {:noreply, assign(socket, button_status: :error)}
  end

  def handle_info(:redirect_to_machine, socket) do
    mach_id = socket.assigns.create_status.result.body["id"]
    Logger.info("About to try redirecting to https://useless-machine.fly.dev/machine/#{mach_id}")
    {:noreply, redirect(socket, external: "https://useless-machine.fly.dev/machine/#{mach_id}")}
  end

  def handle_info(:replay_to_machine, socket) do
    mach_id = socket.assigns.create_status.result.body["id"]
    Logger.info("About to replay to Machine #{mach_id}")
    # Push a redirect that includes the Fly-Replay header
    {:noreply, redirect(socket, to: "/#{mach_id}")}
  end

  def handle_info(:redirect_w_req_header, socket) do
    mach_id = socket.assigns.create_status.result.body["id"]
    Logger.info("About to send request to Machine #{mach_id}")
    # Push a redirect that includes the Fly-Replay header
    {:noreply, redirect(socket, to: "/force_instance/#{mach_id}")}
  end

  def handle_info(:reset_button, socket) do
    Logger.info("reset_button called")
    {:noreply, assign(socket, button_status: :idle, button_text: "Create Machine", create_status: nil)}
  end

  def handle_info({:data, payload}, socket) do
    %{count: count, regions: regions} = payload
    Logger.info("Got a count, regions from api call")
    {:noreply, assign(socket, active_regions: regions, machine_count: count)}
  end

  def maybe_spawn_useless_machine(client) do
    {count, regions} = check_machines(client) |> dbg
    Process.send(self(), {:data, %{count: count, regions: regions}}, [])
    if count < @mach_limit do
      Logger.info("Capacity OK; creating a new Machine")
      Clutterfly.FlyAPI.create_machine(client, @app_name, @mach_params)
    else
      Logger.info("Machine limit reached; not creating a new one.")
      # TODO: set an assign that changes the liveview? Or show a flash message?
      {:error, %{reason: :capacity, message: "Reached capacity; try again later."}}
    end
  end

  def check_machines(client) do
    # Make the API request to get the machines list
    with {:ok, machines} <- Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
      # {3, ["syd", "yyz", "ams"], %{"ams" => 1, "syd" => 1, "yyz" => 1}}
      {count, regions} = Clutterfly.Commands.region_stats(machines)
      {count, regions}
    end
  end

end
