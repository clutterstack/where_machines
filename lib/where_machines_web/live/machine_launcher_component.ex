defmodule WhereMachinesWeb.MachineLauncher do
  use WhereMachinesWeb, :live_component
  alias Phoenix.LiveView.AsyncResult
  alias WhereMachines.MachineLauncher
  require Logger

  def mount(socket) do
    {:ok, assign(socket,
      our_mach: nil
    )}
  end

  def update(assigns, socket) do
      {:ok,
        socket
        |> assign(
          inner_block: assigns.inner_block,
          regions: assigns.regions,
          classes: assigns.classes,
          btn_class: assigns.btn_class)
        |> assign_new( # Only initialize buttons if not already set
          :buttons,
          fn ->
            Map.new(assigns.regions,
            fn region ->
              {region, %{region: region,
                async: %Phoenix.LiveView.AsyncResult{
                  ok?: false,
                  loading: nil,
                  failed: nil,
                  result: nil
                }}}
            end)
          end)
      }
  end

  def render(assigns) do
    ~H"""
    <div class={@classes}>
      <%= for {region, button} <- @buttons do %>
        <button
          id={"button-#{region}"}
          phx-value-region={region}
          phx-value-id={region}
          phx-click="create_machine"
          phx-target={@myself}
          disabled={button_status(button.async) !== :idle}
          class={[@btn_class,
                  button_class(button.async)
                  ]}>
          <span class="button-content">
            <%= button_text(button.async, region) %>
          </span>
        </button>
      <% end %>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # <!-- Orig buttons -->

  # <div class="col-span-4 button-grid">
  #   <%= for {region, button} <- @buttons do %>
  #     <RegionButton.region_button id={region} async={button.async} label={"#{region} launch button"} />
  #   <% end %>
  # </div>


  def handle_event("create_machine", %{"region" => region, "id" => button_id}, socket) do
    # region |> dbg
    id_atom = String.to_existing_atom(button_id)
    updated_buttons = new_buttons_assign(id_atom, :loading, :waiting, socket)
    {:noreply,
     socket
     |> assign(buttons: updated_buttons)
     |> start_async(:create_machine_task, fn -> MachineLauncher.maybe_spawn_useless_machine(id_atom, region) end)
    }
  end

  #####
  # Async task return handling
  ######

  def handle_async(:create_machine_task, {:ok, {:ok, %{requestor_id: button_id, machine_id: machine_id, status_map: status_map}}}, socket) do
    Logger.info("Machine created successfully.")
    Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_added, {machine_id, status_map}})
    data = %{machine_id: machine_id, status_map: status_map}
    updated_buttons = new_buttons_assign(button_id, :ok, data, socket)
    # updated_machines = new_machines_assign(%{machine_id: machine_id, status_map: status_map}, socket)
    {:noreply, assign(socket, buttons: updated_buttons, our_mach: machine_id)}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{requestor_id: button_id, stuff: %Req.TransportError{reason: :timeout}}}}, socket) do
    Logger.error("Machine creation request timed out")
    updated_buttons = new_buttons_assign(button_id, :failed, :timeout, socket)
    Process.send_after(self(), {:reset_button, button_id}, 3000)
    {:noreply, assign(socket, buttons: updated_buttons)}
  end

  def handle_async(:create_machine_task, {:error, %{requestor_id: button_id, stuff:  %Req.TransportError{reason: :capacity}}}, socket) do
    updated_buttons = new_buttons_assign(button_id, :failed, :capacity, socket)
    Logger.info("No capacity")
    Process.send_after(self(), {:reset_button, button_id}, 3000)
    {:noreply, assign(socket, buttons: updated_buttons)}
  end

  def handle_async(:create_machine_task, {:ok, {:error, %{requestor_id: button_id, stuff: stuff}}}, socket) do
    updated_buttons = new_buttons_assign(button_id, :failed, stuff, socket)
    Logger.error("Machine creation failed: #{inspect stuff}")
    Process.send_after(self(), {:reset_button, button_id}, 3000)
    {:noreply, assign(socket, buttons: updated_buttons)}
  end

  def handle_async(:create_machine_task, {:exit, %{message: message}}, socket) do
    Logger.error("Machine creation task crashed with message: #{message}")
    {:noreply, socket}
  end

  #####################################################################
  # Handle messages from self
  #####################################################################

  def handle_info({:reset_button, button_id}, socket) do
    Logger.info("reset_button called")
    updated_buttons = new_buttons_assign(button_id, :reset, :idle, socket)
    {:noreply, assign(socket, buttons: updated_buttons, our_mach: nil)}
  end

  #####################################################################
  # Handle machine ready message from API controller via PubSub.
  #####################################################################

  def handle_info({:machine_ready, %{machine_id: machine_id, status_map: %{region: region}}}, socket) do
    Logger.info("MachineLauncher got a :machine_ready message from PubSub for #{machine_id}.")
    # If that's our Machine started, redirect the client to the useless machine app
    our_mach = socket.assigns.our_mach
    # TODO: Check buttons assigns for machine id instead (which means storing machine id)
    Logger.info("our_mach: #{our_mach}; machine: #{machine_id}")

    if machine_id == our_mach do
      Logger.info("That's our Machine. We can redirect if we want.")
      Process.send_after(self(), :our_machine_ready, 100)
    end
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    Logger.info("MachineLauncher received unknown message: #{inspect message}")
    {:noreply, socket}
  end

  #####################################################################
  # Update individual button entries in the buttons assign
  #####################################################################

  defp new_buttons_assign(button_id, :ok, %{machine_id: machine_id, status_map: _status_map}, socket) do
    Map.update!(socket.assigns.buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok(machine_id)}
    end)
  end

  defp new_buttons_assign(button_id, :reset, :idle, socket) do
    Logger.info("In new_buttons_assign, resetting button async value to :idle")
    Map.update!(socket.assigns.buttons, button_id, fn button ->
      %{button | async: %Phoenix.LiveView.AsyncResult{
        ok?: false,
        loading: nil,
        failed: nil,
        result: nil
      }}
      end) |> dbg
  end

  defp new_buttons_assign(button_id, :ok, value, socket) do
    Map.update!(socket.assigns.buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok(value)}
      end) |> dbg
  end

  defp new_buttons_assign(button_id, :failed, reason, socket) do
    Map.update!(socket.assigns.buttons, button_id, fn button ->
      %{button | async: AsyncResult.failed(button.async, reason)}
    end) |> dbg
  end

  defp new_buttons_assign(button_id, :loading, loading_state, socket) do
    Map.update!(socket.assigns.buttons, button_id, fn button ->
      %{button | async: AsyncResult.loading(button.async, loading_state)}
    end) |> dbg
  end

  defp button_text(async, region) do
    cond do
      async.loading -> "Loading"
      async.ok? -> "Launched in #{region}"
      async.failed -> "Failed"
      true -> region
    end
  end

  defp button_status(async) do
    cond do
      async.loading -> :loading
      async.ok?  -> :success
      async.failed -> :failed
      true -> :idle
    end
  end

  defp button_class(async) do
    cond do
      async.loading -> "btn bg-amber-500 from-yellow-300 to-yellow-50"
      async.ok? -> "btn bg-green-500"
      async.failed -> "btn bg-red-500"
      true -> "btn bg-stone-800"
    end
  end

end
