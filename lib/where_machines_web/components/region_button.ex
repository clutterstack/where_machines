defmodule WhereMachinesWeb.Components.RegionButton do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :phx_click_assign, :string
  attr :phx_target_assign, :string, default: "@myself"
  attr :async, :any, default: nil
  attr :label, :string, default: nil
  attr :region, :string, default: ""


  def region_button(assigns) do
    ~H"""
    <button
      id={"button-#{@id}"}
      phx-value-region={@id}
      phx-value-id={@id}
      phx-click={@phx_click_assign}
      phx-target={@phx_target_assign}
      disabled={button_status(@async) !== :idle}
      class={[@class,
              button_class(@async)
              ]}>
      <span class="button-content">
        <%= button_text(@async, @id) %>
      </span>
    </button>
    """
  end

  # Helper functions for button appearance
  defp button_class(async) do
    cond do
      async.loading -> "btn-primary btn-loading"
      async.ok? and async.result == "Launched" -> "btn-success"
      async.ok? -> "btn-primary"
      async.failed -> "btn-danger"
    end
  end

  defp button_status(async) do
    cond do
      async.loading -> :loading
      async.ok? and async.result == "Launched" -> :success
      async.ok? -> :idle
      async.failed -> :failed
    end
  end

  defp button_text(async, label) do
      cond do
        # async.loading(:idle) -> "Idle"
        async.loading -> "Loading..."
        async.ok? -> async.result
        async.failed -> "Error!"
        is_binary(label) -> label

      end
  end


end
