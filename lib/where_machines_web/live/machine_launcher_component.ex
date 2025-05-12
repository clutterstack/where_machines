defmodule WhereMachinesWeb.MachineLauncher do
  use WhereMachinesWeb, :live_component
  alias Phoenix.LiveView.AsyncResult
  alias WhereMachines.MachineLauncher
  require Logger

  @reset_after_success 20000
  @reset_after_failure 5000
  @base_class_single "col-span-4 row-start-1 row-span-2 col-start-1 grid grid-cols-subgrid grid-rows-subgrid"
  @base_class_multi "col-span-4 grid grid-cols-4 gap-4 sm:gap-8"
  @btn_class_single "absolute
                  w-16 h-16 rounded-full
                  border border-[#DAA520]
                  text-transparent
                  cursor-pointer z-10
                  shadow-lg
                  hover:shadow-xl
                  active:scale-95
                  transition-all
                  duration-300"

  @btn_class_multi "px-4 py-2 my-2 rounded-lg border border-[#DAA520]"

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(
        id: assigns.id,
        # inner_block: assigns.inner_block,
        regions: assigns.regions,
        variant: assigns.variant,
        # fly_edge_region: assigns.fly_edge_region,
        btn_class: assigns.variant == :single && @btn_class_single || @btn_class_multi,
        base_class: assigns.variant == :single && @base_class_single || @base_class_multi,
        our_mach_state: assigns.our_mach_state)
      |> assign_new(:timer_ref, fn -> nil end)
      |> assign_new(:current_timer_display, fn -> "0.0s" end)
      |> assign_new( # Only initialize buttons if not already set
        :buttons,
        fn ->
          Keyword.new(assigns.regions |> Enum.sort(),
          fn region ->
            {region, %{region: region,
              async: %Phoenix.LiveView.AsyncResult{
                ok?: false,
                loading: nil,
                failed: nil,
                result: nil
              },
              # Add timer state to each button
              start_time: nil,
              elapsed_time: nil
            }}
          end)
          # |> Enum.sort_by( fn {key, _val} -> key end)
        end)
    }
  end
# ml-[8rem] sm:ml-[20rem]
  def render(assigns) do
    ~H"""
    <div class={@base_class}>

      <%= if @variant == :single do %>
            <div class="col-start-2 col-span-3
                        sm:mr-32">

          <div class="panel  w-32 sm:w-48 mx-auto
                      flex flex-col justify-center items-center">
            <%= for {region, button} <- @buttons do %>
              <div class="relative rounded-full border-2 border-zinc-700
                          my-8
                          w-20 h-20
                          flex justify-center items-center">
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
              </div>

              <div class="text-2xl sm:text-3xl mb-4">START</div>
            <% end %>
            </div>
                      </div>

          <%= for {region, button} <- @buttons do %>
                <div class="col-span-4 mt-4 font-mono text-xs text-zinc-200">
                  {message(button.async)}
                  <%= if should_show_timer?(button) do %>
                    <span class="ml-2 text-amber-400 font-bold">
                      {@current_timer_display}
                    </span>
                  <% end %>
                </div>
          <% end %>

      <% else %>

          <div class="panel col-span-4 grid grid-cols-4 gap-x-4 sm:gap-x-6">
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
                <%= button_text(button.async, region) %>
            </button>
          <% end %>
        </div>

      <% end %>

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
    # Start the timer for this button
    updated_buttons = new_buttons_assign(id_atom, :loading, :waiting, socket.assigns.buttons)
                    |> start_button_timer(id_atom)

    # Start the display timer only for single variant
    timer_ref = if socket.assigns.variant == :single do
      start_display_timer()
    else
      nil
    end

    {:noreply,
     socket
     |> assign(buttons: updated_buttons, timer_ref: timer_ref)
     |> start_async({:create_machine_task, id_atom}, fn ->
        # Get the start time for this button to pass to the spawn function
        start_time = get_in(updated_buttons, [id_atom, :start_time])
        MachineLauncher.maybe_spawn_useless_machine(id_atom, region, start_time)
     end)
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
    Logger.debug("MachineLauncher component sending :our_mach_created to parent: #{inspect {machine_id, status_map}}")
    Process.send(self(), {:our_mach_created, {machine_id, status_map}}, [])
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async({:wait_for_machine_task, machine_id, button_id}, fn -> MachineLauncher.wait_for_machine_to_start(machine_id) end)
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

  #this one happened: stuff was  %Req.TransportError{reason: :closed}
  def handle_async({:create_machine_task, button_id}, {:ok, {:error, %{requestor_id: _req_id, stuff: stuff}}}, socket) do
    updated_buttons = new_buttons_assign(button_id, :failed, stuff, socket.assigns.buttons)
    Logger.error("❌ Machine creation failed; stuff: #{inspect stuff}")
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

  # Machine awaiter

  #{:ok, %{status: :started, machine_id: "d8d976ece50628"}}
  def handle_async({:wait_for_machine_task, mach_id, button_id}, {:ok, {:ok, %{status: :started}}}, socket) do
    Logger.debug("wait_for_machine_task returned {:ok, %{status: :started}}")
    Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_started, mach_id})

    # Calculate elapsed time when machine becomes ready
    elapsed_ms = get_elapsed_time_ms(socket.assigns.buttons[button_id])
    elapsed_str = format_ms_for_env(elapsed_ms)

    updated_buttons = new_buttons_assign(button_id, :started, mach_id, socket.assigns.buttons)
                     |> stop_button_timer(button_id, elapsed_ms)

    # Stop the display timer
    socket = stop_display_timer(socket)

    # Send the elapsed time to the parent
    Process.send(self(), {:machine_timer_elapsed, {mach_id, elapsed_str}}, [])

    {:noreply,
    socket
    |> assign(buttons: updated_buttons)
    |> start_async({:reset_button_task, button_id}, fn -> maybe_reset_button(button_id, @reset_after_success) end)
     }
  end


  def handle_async({:wait_for_machine_task, mach_id, button_id}, {:ok, {:error, %{stuff: %Req.TransportError{reason: :timeout}}}}, socket) do
    Logger.error("❌ Wait for machine start timed out (Machine #{mach_id})")
    updated_buttons = new_buttons_assign(button_id, :failed, :timeout, socket.assigns.buttons)
    {:noreply,
      socket
      |> assign(buttons: updated_buttons)
      |> start_async(:reset_button_task, fn -> maybe_reset_button(button_id, @reset_after_failure) end)
    }
  end

  # {:ok, %{status: :started, machine_id: "080e694c6e24d8"}}
  def handle_async({:wait_for_machine_task, mach_id, button_id}, {:ok, something}, socket) do
    Logger.warning("wait_for_machine_task with mach_id #{mach_id} and button_id #{button_id} returned {:ok, something} where something is #{inspect something}")
    {:noreply, socket}
  end

  def handle_async({:wait_for_machine_task, mach_id, button_id}, {:exit, something}, socket) do
    Logger.warning("wait_for_machine_task with mach_id #{mach_id} and button_id #{button_id} returned {:exit, something} where something is #{inspect something}")
    {:noreply, socket}
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


  def handle_info(:timer_tick, socket) do
    # Find the active button with a start_time
    active_button = Enum.find(socket.assigns.buttons, fn {_id, button} ->
      button.start_time != nil && button.elapsed_time == nil
    end)

    case active_button do
      {_id, button} ->
        elapsed_time = format_elapsed_time(button.start_time)
        # Schedule the next tick
        timer_ref = if socket.assigns.variant == :single do
          Process.send_after(self(), :timer_tick, 100)
        else
          nil
        end
        {:noreply, assign(socket, current_timer_display: elapsed_time, timer_ref: timer_ref)}
      _ ->
        # No active timer, stop the ticker
        {:noreply, stop_display_timer(socket)}
    end
  end



  # For async :reset_button_task
  defp maybe_reset_button(button_id, ms) do
    Process.sleep(ms)
    Logger.debug("maybe_reset_button about to return")
    {:ok, button_id}
  end

  # Timer management helpers
  defp start_button_timer(buttons, button_id) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | start_time: System.system_time(:millisecond)}
    end)
  end

  defp stop_button_timer(buttons, button_id, elapsed_ms) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | elapsed_time: elapsed_ms}
    end)
  end

  defp get_elapsed_time_ms(%{start_time: nil}), do: 0
  defp get_elapsed_time_ms(%{start_time: start_time}) do
    System.system_time(:millisecond) - start_time
  end

  defp format_elapsed_time(nil), do: "0.0s"
  defp format_elapsed_time(start_time) do
    elapsed_ms = System.system_time(:millisecond) - start_time
    elapsed_s = elapsed_ms / 1000
    :io_lib.format("~.1fs", [elapsed_s]) |> to_string()
  end

  defp format_ms_for_env(elapsed_ms) do
    "#{elapsed_ms}ms"
  end

  # Display timer management
  defp start_display_timer do
    Process.send_after(self(), :timer_tick, 100)
  end

  defp stop_display_timer(socket) do
    if socket.assigns.timer_ref do
      Process.cancel_timer(socket.assigns.timer_ref)
    end
    assign(socket, timer_ref: nil)
  end

  defp should_show_timer?(button) do
    button.start_time != nil && button.elapsed_time == nil
  end


  #####################################################################
  # Update individual button entries in the buttons assign
  #####################################################################

  defp new_buttons_assign(button_id, :reset, :idle, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | async: %Phoenix.LiveView.AsyncResult{
        ok?: false,
        loading: nil,
        failed: nil,
        result: nil
      }}
    end)
  end

  defp new_buttons_assign(button_id, :ok, %{machine_id: machine_id, status_map: _status_map}, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok({machine_id, :created})}
    end)
  end

  defp new_buttons_assign(button_id, :started, machine_id, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok({machine_id, :started})}
    end)
  end

  defp new_buttons_assign(button_id, :ok, value, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.ok(value)}
    end)
  end

  defp new_buttons_assign(button_id, :failed, reason, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
      %{button | async: AsyncResult.failed(button.async, reason)}
    end)
  end

  defp new_buttons_assign(button_id, :loading, loading_state, buttons) do
    Keyword.update!(buttons, button_id, fn button ->
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
      async.loading -> "btn bg-neutral-300"
      async.ok? && elem(async.result, 1) == :created -> "btn bg-amber-400" # {"78116d0f960798", :created}
      async.ok? && elem(async.result, 1) == :listening -> "btn bg-green-500" # {"78116d0f960798", :created}
      async.ok? && elem(async.result, 1) == :started-> "btn bg-sky-200" # started
      async.failed -> "btn bg-red-500"
      true -> "btn bg-stone-600"
    end
  end

  defp message(async) do
    cond do
      async.loading -> "Requested Useless Machine. Awaiting API response..."
      async.ok? && elem(async.result, 1) == :started -> "Machine #{elem(async.result, 0)} started. Waiting for it to be ready to serve requests..."
      async.ok? && elem(async.result, 1) == :listening -> "Machine #{elem(async.result, 0)} ready! About to redirect..."
      async.ok? -> "Machine #{elem(async.result, 0)} created. Waiting for it to reach started state..."
      async.failed -> "Failed to launch a new Useless Machine: #{inspect async.result}"
      true -> ">"
    end
  end

end
