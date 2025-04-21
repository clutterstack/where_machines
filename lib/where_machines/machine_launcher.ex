defmodule WhereMachines.MachineLauncher do

  require Logger
  alias WhereMachines.MachineTracker
  import WhereMachines.MachineParams

  @mach_limit 8
  @app_name "useless-machine"

  def maybe_spawn_useless_machine(id, region \\ "") do
    region = validate_region(region)
    # If tracker says we have capacity, verify with ETS if fresh or API if not
    case MachineTracker.get_fresh_count() do

      {:ok, api_count, _} -> Logger.debug("MachineLauncher got count #{api_count} from tracker")
          if api_count < @mach_limit do
            Logger.debug("Tracker says we're below our limit; creating a new Machine")
            spawn_machine(id, region)
          else
            Logger.info("Machine limit reached; not creating a new one.")
            {:error, %{requestor_id: id, reason: :capacity, message: "Reached capacity; try again later."}}
          end

      {:timeout, stuff} ->
        Logger.debug("the genserver timed out: #{inspect stuff}")
        {:error, %{requestor_id: id, reason: :genserver_timeout, stuff: stuff}}
    end

  end

  defp spawn_machine(id, region) do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
    case Clutterfly.FlyAPI.create_machine(client, @app_name, Enum.into(%{region: region}, useless_params())) do
      {:ok, %{status: 200, body: %{"id" => machine_id, "region" => region, "state" => state}}} ->
        status_map = %{
          status: state,
          region: region,
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }
        {:ok, %{requestor_id: id, machine_id: machine_id, status_map: status_map}}

      {:error, stuff} -> Logger.error("Button #{id} got an error from the API: #{inspect stuff}")
        {:error, %{requestor_id: id, stuff: stuff}}


      other -> Logger.warning("create_machine returned unanticipated response #{inspect other}")
        {:error, "unanticipated response"}
    end

  end

  defp validate_region(region) do
    region_atom = String.to_existing_atom(region)
    if (Map.has_key?(WhereMachines.CityData.cities(), region_atom)) do
      region
    else
      Logger.warning("#{region} is not a valid region. Falling back to platform default region.")
      ""
    end
  end

end
