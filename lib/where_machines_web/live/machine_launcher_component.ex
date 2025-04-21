defmodule WhereMachinesWeb.MachineLauncher do
  use WhereMachinesWeb, :live_component
  alias Phoenix.LiveView.AsyncResult
  alias WhereMachines.MachineLauncher
  require Logger

  @reset_after_success 20000
  @reset_after_failure 5000

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(
        id: assigns.id,
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
    id_atom = String.to_existing_atom(button_id)
    updated_buttons = new_buttons_assign(id_atom, :loading, :waiting, socket.assigns.buttons)
    {:noreply,
     socket
     |> assign(buttons: updated_buttons)
     |> start_async({:create_machine_task, id_atom}, fn -> MachineLauncher.maybe_spawn_useless_machine(id_atom, region) end)
    }
  end

  #####
  # Async task return handling
  ######

  def handle_async({:create_machine_task, button_id}, {:ok, {:ok, %{requestor_id: _req_id, machine_id: machine_id, status_map: status_map}}}, socket) do
    Logger.info("✅ Machine #{machine_id} created in #{status_map.region}.")
    Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_added, {machine_id, status_map}})
    data = %{machine_id: machine_id, status_map: status_map}
    updated_buttons = new_buttons_assign(button_id, :ok, data, socket.assigns.buttons)
    Logger.debug("MachineLauncher component sending :our_mach_created to parent: #{inspect %{machine_id: machine_id, region: button_id}}")
    Process.send(self(), {:our_mach_created, {button_id, machine_id}}, [])
    # updated_machines = new_machines_assign(%{machine_id: machine_id, status_map: status_map}, socket)
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async({:reset_button_task, button_id}, fn -> maybe_reset_button(button_id, @reset_after_success) end)
    }
  end

  def handle_async({:create_machine_task, button_id}, {:ok, {:error, %{requestor_id: _req_id, stuff: %Req.TransportError{reason: :timeout}}}}, socket) do
    Logger.error("❌ Machine creation request timed out")
    updated_buttons = new_buttons_assign(button_id, :failed, :timeout, socket.assigns.buttons)
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
    }
  end

  # This one is needed for sure. Task returned OK, but MachineLauncher function returned an error
  def handle_async({:create_machine_task, button_id}, {:ok, {:error, %{requestor_id: _req_id, reason: :capacity, message: message}}}, socket) do
    updated_buttons = new_buttons_assign(button_id, :failed, :capacity, socket.assigns.buttons)
    Logger.warning("❌ Capacity reached; try again later #{inspect message}")
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
    }
  end

  def handle_async({:create_machine_task, button_id}, {:ok, {:error, %{requestor_id: _req_id, reason: reason, stuff: stuff}}}, socket) do
    updated_buttons = new_buttons_assign(button_id, :failed, stuff, socket.assigns.buttons)
    Logger.error("❌ Machine creation failed for reason #{reason}: #{inspect stuff}")
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
     }
  end

  def handle_async({:create_machine_task, button_id}, {:exit, {:timeout, stuff}}, socket) do
    Logger.error("❌ Machine creation task crashed with a timeout: #{inspect stuff}")
    {:noreply,
      socket
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
    }
  end


  def handle_async({:create_machine_task, button_id}, {:exit, %{message: message}}, socket) do
    Logger.error("❌ Machine creation task crashed with message: #{message}")
    {:noreply,
      socket
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
    }
  end

  # Button resetter

  def handle_async({:reset_button_task, button_id}, {:ok, {:ok, _btn_id}}, socket) do
    Logger.debug("Resetting button #{button_id} in response to async task")
    updated_buttons = new_buttons_assign(button_id, :reset, :idle, socket.assigns.buttons)
    {:noreply, assign(socket, buttons: updated_buttons)}
  end

  def handle_async({:reset_button_task, _button_id}, return_value, socket) do
    Logger.debug(":reset_button_task return value: #{inspect return_value}")
    {:noreply, socket}
  end

  # For async :reset_button_task
  defp maybe_reset_button(button_id, ms) do
    Process.sleep(ms)
    Logger.debug("maybe_reset_button about to return")
    {:ok, button_id}
  end

  #####################################################################
  # Update individual button entries in the buttons assign
  #####################################################################

  defp new_buttons_assign(button_id, :reset, :idle, buttons) do
    Map.update!(buttons, button_id, fn button ->
      %{button | async: %Phoenix.LiveView.AsyncResult{
        ok?: false,
        loading: nil,
        failed: nil,
        result: nil
      }}
    end)
  end

  defp new_buttons_assign(button_id, :ok, %{machine_id: machine_id, status_map: _status_map}, buttons) do
    Map.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok(machine_id)}
    end)
  end

  defp new_buttons_assign(button_id, :ok, value, buttons) do
    Map.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok(value)}
    end)
  end

  defp new_buttons_assign(button_id, :failed, reason, buttons) do
    Map.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.failed(button.async, reason)}
    end)
  end

  defp new_buttons_assign(button_id, :loading, loading_state, buttons) do
    Map.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.loading(button.async, loading_state)}
    end)
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
