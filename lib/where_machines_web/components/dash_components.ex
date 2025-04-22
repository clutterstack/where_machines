defmodule WhereMachinesWeb.DashComponents do
  use Phoenix.Component
  require Logger

  def machine_table(assigns) do
    ~H"""
    <!-- Machine table -->
    <div class="panel col-span-3">
      <h3 class="text-lg font-semibold text-yellow-300 mb-2">Useless Machines (Total {Enum.count(@machines)})</h3>
      <div class="w-full overflow-x-auto text-sm">
        <table class="min-w-full">
          <thead>
            <tr>
              <th :if={@live_action == :all_regions} class="py-2 px-4 border-b border-zinc-700 text-left">ID</th>
              <th class="py-2 px-4 border-b border-zinc-700 text-left">Region</th>
              <th class="py-2 px-4 border-b border-zinc-700 text-left">Status</th>
              <th class="py-2 px-4 border-b border-zinc-700 text-left">Last Update</th>
            </tr>
          </thead>
          <tbody>
            <%= for {id, status_map} <- @machines do %>
              <tr class="hover:bg-zinc-700 transition-colors">
                <td :if={@live_action == :all_regions} class="py-2 px-4 border-b border-zinc-700"><%= id %></td>
                <td class="py-2 px-4 border-b border-zinc-700"><%= status_map.region %></td>
                <td class="py-2 px-4 border-b border-zinc-700">
                  <span class={status_class(status_map.status)}>
                    <%= status_map.status %>
                  </span>
                </td>
                <td class="py-2 px-4 border-b border-zinc-700">
                  <%= format_time(status_map.timestamp) %>
                </td>
              </tr>
            <% end %>
            <%= if Enum.empty?(@machines) do %>
              <tr>
                <td colspan="5" class="py-4 text-center text-zinc-500">No Machines</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def region_summaries(assigns) do
    ~H"""
    <h3 class="text-lg font-semibold text-yellow-300 mb-2">Active Regions</h3>
    <%= for {region, count} <- region_stats(@machines) do %>
      <p>{region}: {count}</p>
    <% end %>
    """
  end


   @doc """
  Number of Machines by region
  %{"ams" => 1}
  """
  def region_stats(machines) do
    machines
    |> Enum.reduce(%{}, fn {_key, %{region: region}}, acc ->
      Map.update(acc, region, 1, &(&1 + 1))
    end)
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

end
