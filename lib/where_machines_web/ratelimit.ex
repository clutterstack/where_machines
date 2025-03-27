defmodule WhereMachinesWeb.RateLimit do
  use GenServer
  require Logger

  @sweep_after :timer.seconds(60)
  @tab :advanced_ip_rate_limiter_requests

  ## Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Logs a request for the given IP address and path.
  Returns :ok if the request is allowed, or {:error, :rate_limited} if the
  IP has exceeded the maximum number of requests per minute for that path.

  The key in ETS is {ip, path_key} where path_key is derived from the path
  """
  def log_request(ip, path, max_requests) do
    path_key = get_path_key(path)
    key = {ip, path_key}

    case :ets.update_counter(@tab, key, {2, 1}, {key, 0}) do
      count when count > max_requests -> {:error, :rate_limited}
      count -> {:ok, count}
    end
  end

  @doc """
  Returns the current request count for an IP address and path
  """
  def request_count(ip, path) do
    path_key = get_path_key(path)
    key = {ip, path_key}

    case :ets.lookup(@tab, key) do
      [{^key, count}] -> count
      [] -> 0
    end
  end

  ## Server
  def init(_) do
    :ets.new(@tab, [:set, :named_table, :public, read_concurrency: true,
                                               write_concurrency: true])
    schedule_sweep()
    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    Logger.debug("Sweeping IP rate limit requests")
    :ets.delete_all_objects(@tab)
    schedule_sweep()
    {:noreply, state}
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_after)
  end

  # Helper to convert a path to a key
  # You can customize this to group similar paths together
  defp get_path_key(path) do
    cond do
      # Group all login attempts together
      String.match?(path, ~r{^/api/auth/(login|reset|password)}) ->
        "auth"

      # Group all API data endpoints
      String.match?(path, ~r{^/api/data}) ->
        "data"

      # Default: use the full path
      true ->
        path
    end
  end
end
