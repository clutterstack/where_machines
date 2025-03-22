defmodule WhereMachinesWeb.IndexLive do
  use WhereMachinesWeb, :live_view
  alias Phoenix.LiveView.AsyncResult
  require Logger

  @mach_params WhereMachines.MachineParams.useless_params()

  @app_name "useless-machine"

  @mach_limit 3

  def mount(_params, %{"fly_region" => fly_edge_region}, socket) do
    {:ok, assign(socket,
      fly_edge_region: fly_edge_region,
      create_status: nil,
      button_status: :idle,  # :idle, :success, :error
      button_text: "Create Machine"
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Create Machine</h1>
      <div>Your Fly.io edge region is <%= @fly_edge_region %></div>
      <button
        phx-click={@button_status === :idle &&
        "create_machine" || nil}
        class={button_class(@button_status)}
        >
          {@button_text}
        </button>

      <%= if @create_status do %>
        <.async_result :let={result} assign={@create_status}>
          <:loading>Waiting for API response.</:loading>
          <:failed :let={reason}>{reason}</:failed>
          <div>Machine created in {result.body["region"]}</div>
          <div>{result.body["id"]}</div>
          <div>{result.body["private_ip"]}</div>
        </.async_result>
      <% end %>
    </div>
    """
  end

  defp button_class(:idle), do: "btn bg-black text-white"
  defp button_class(:starting), do: "btn bg-amber-500 text-black"
  defp button_class(:success), do: "btn bg-green-500 text-black"
  defp button_class(:error), do: "btn bg-red-500 text-white"

  def handle_event("create_machine", _params, socket) do
    Logger.info("received create_machine event for app_name #{@app_name}")
    {:noreply,
     socket
     |> assign(button_status: :starting, button_text: "Creating Machine", create_status: AsyncResult.loading())
     #the :create_status assign is now an AsyncResult struct with loading: true
     |> start_async(:create_machine_task, fn -> maybe_spawn_useless_machine() end)
    }
  end

  def handle_async(:create_machine_task, {:ok, {:ok, result}}, socket) do
    # Success: Machine created
    Logger.info("Returned success")
    Process.send_after(self(), :redirect_to_machine, 3000)
    {:noreply, assign(socket,
      button_status: :success,
      button_text: "Machine created",
      create_status: AsyncResult.ok(result))}
  end

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

  def maybe_spawn_useless_machine() do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
    case Clutterfly.Commands.count_machines(@app_name, client: client) do
      {:ok, num_mach} when is_number(num_mach) ->
        Logger.info("got a number of Machines: #{num_mach}")
        if num_mach < @mach_limit do
          Clutterfly.FlyAPI.create_machine(client, @app_name, @mach_params)
        else
          Logger.info("Machine limit reached; not creating a new one.")
          # TODO: set an assign that changes the liveview? Or show a flash message?
          {:error, %{reason: :capacity, message: "Reached capacity; try again later."}}
        end
      {:error, message} -> {:error, message}
    end
  end

end
