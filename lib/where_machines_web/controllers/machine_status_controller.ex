defmodule WhereMachinesWeb.MachineStatusController do
  use WhereMachinesWeb, :controller
  require Logger

  @doc """
  Receives status updates from useless_machine instances
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

      Logger.info("Received status update for machine #{machine_id}: #{status}")

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
