defmodule WhereMachines.Plugs.RateLimit do
  @moduledoc """
  A plug for rate limiting requests by IP address and path.

  This plug uses an ETS table to track requests and can be applied
  to specific routes or the entire application with different limits
  for different paths.
  """

  import Plug.Conn
  require Logger
  alias WhereMachinesWeb.RateLimit

  @doc """
  Initialize the plug with options

  ## Options

    * `:max_requests` - maximum number of requests allowed per minute (default: 5)
    * `:error_handler` - a function to handle rate limiting errors (optional)
    * `:path_limits` - a map of path patterns to custom limits (optional)
      Example: %{~r{^/api/login} => 3, ~r{^/api/data} => 10}
  """
  def init(opts) do
    %{
      max_requests: Keyword.get(opts, :max_requests, 5),
      error_handler: Keyword.get(opts, :error_handler),
      path_limits: Keyword.get(opts, :path_limits, %{})
    }
  end

  @doc """
  Call the plug
  """
  def call(conn, opts) do
    ip = get_client_ip(conn)
    path = conn.request_path
    Logger.info("RateLimit plug called with ip #{ip}")

    # Determine the limit for this path
    limit = get_limit_for_path(path, opts)

    case RateLimit.log_request(ip, path, limit) do
      {:ok, count} ->
        # Add rate limit headers to the response
        remaining = limit - count

        conn
        |> put_resp_header("x-rate-limit-limit", to_string(limit))
        |> put_resp_header("x-rate-limit-remaining", to_string(max(0, remaining)))

      {:error, :rate_limited} ->
        # Use custom error handler if provided, otherwise use default
        if opts.error_handler do
          opts.error_handler.(conn, limit)
        else
          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header("x-rate-limit-limit", to_string(limit))
          |> put_resp_header("x-rate-limit-remaining", "0")
          |> send_resp(429, Jason.encode!(%{error: "Rate limit exceeded"}))
          |> halt()
        end
    end
  end

  # Get client IP from conn
  defp get_client_ip(conn) do
    conn.remote_ip
    |> :inet.ntoa()
    |> to_string()
  end

  # Get the appropriate limit for the current path
  defp get_limit_for_path(path, opts) do
    # Check if there's a custom limit for this path
    Enum.find_value(opts.path_limits, opts.max_requests, fn {pattern, limit} ->
      if String.match?(path, pattern), do: limit, else: nil
    end)
  end
end
