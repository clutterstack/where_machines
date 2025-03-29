defmodule WhereMachinesWeb.MachineStatusController do
  use WhereMachinesWeb, :controller
  require Logger

  @doc """
  Receives status updates via HTTP POST requests from useless_machine instances, and invokes MachineTracker.update_status() which updates the ETS table tracking Useless Machines, and broadcasts the update on PubSub, so that IndexLive knows to get the latest data from the table.

  Expected payload format:
  {
    "machine_id": "12345",
    "status": "started" | "stopping",
    "region": "yyz",
    "timestamp": "2025-03-28T12:34:56Z"
  }
  """
  def update(conn, params) do
    with {:ok, machine_id} <- Map.fetch(params, "machine_id"),
         {:ok, status} <- Map.fetch(params, "status"),
         {:ok, region} <- Map.fetch(params, "region") do

      timestamp = params["timestamp"] || DateTime.utc_now() |> DateTime.to_iso8601()

      # Store the status and broadcast to interested processes
      WhereMachines.MachineTracker.update_status(machine_id, %{
        status: status,
        region: region,
        timestamp: timestamp
      })

      Logger.info("Received HTTP status update from Useless Machine for #{machine_id}: #{status}")

      conn
      |> put_status(:ok)
      |> json(%{success: true})
    else
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing required fields"})
    end
  end
end
