defmodule WhereMachinesWeb.APIController do
  use WhereMachinesWeb, :controller
  require Logger

  @doc """
  Receives status updates via HTTP POST requests from useless_machine instances, and invokes MachineTracker.update_from_http() which updates the ETS table tracking Useless Machines, and broadcasts the update on PubSub, so that IndexLive knows to get the latest data from the table.

  Expected payload format:
  {
    "machine_id": "12345",
    "status": "listening" | "stopping",
    "region": "yyz",
    "timestamp": "2025-03-28T12:34:56Z"
  }
  """
  def update(conn, %{"machine_id" => machine_id, "status" => status, "region" => region} = params) do
    Logger.info("Received HTTP status update from Useless Machine for #{machine_id}: #{status}")

      timestamp = params["timestamp"] || DateTime.utc_now() |> DateTime.to_iso8601()

      # Store the status and broadcast to interested processes
      status_map = %{
        status: status,
        region: region,
        timestamp: timestamp
      }
      Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_ready, {machine_id, status_map}})
      conn
      |> put_status(:ok)
      |> json(%{success: true})
  end

  def update(conn, %{"machine_id" => machine_id}) do
    Logger.debug("Received HTTP status update from Useless Machine for #{machine_id}. (Means it's stopping)")
      Phoenix.PubSub.broadcast(:where_pubsub, "machine_updates", {:machine_stopping, machine_id})
      conn
      |> put_status(:ok)
      |> json(%{success: true})
  end

  def update(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required fields"})
  end

end
