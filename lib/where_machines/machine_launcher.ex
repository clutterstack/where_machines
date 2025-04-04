defmodule WhereMachines.MachineLauncher do

  require Logger
  alias WhereMachines.MachineTracker
  import WhereMachines.MachineParams

  @mach_limit 3
  @app_name "useless-machine"

  def maybe_spawn_useless_machine(id, region \\ "") do
    region = validate_region(region)

    # First check tracker (fast)
    {count, _regions, _} = MachineTracker.region_stats()

    if count < @mach_limit do
      Logger.info("Local tracker indicates capacity; check with API and try to launch a new Machine")
      client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("FLY_API_TOKEN"))
      # If tracker says we have capacity, verify with API
      case Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
        {:ok, api_machines} ->
          MachineTracker.update_all_from_api(api_machines)
          # Count running machines from API
          api_count = Enum.count(api_machines)

          if api_count < @mach_limit do
            Logger.info("API says we have capacity; creating a new Machine")
            spawn_machine(client, id, region)
          else
            Logger.info("API check shows no capacity; not creating a new Machine")
            {:error, %{requestor_id: id, reason: :capacity, message: "At capacity; try again later"}}
          end

        {:error, reason} ->
          # API check failed, fall back to tracker data
          Logger.warning("API check failed: #{inspect(reason)}. Falling back to tracker data.")
          spawn_machine(client, id, region)
        end
    else
      Logger.info("Machine limit reached; not creating a new one.")
      {:error, %{requestor_id: id, reason: :capacity, message: "Reached capacity; try again later."}}
    end
  end

  defp spawn_machine(client, id, region) do
    case Clutterfly.FlyAPI.create_machine(client, @app_name, Enum.into(%{region: region}, useless_params())) do
      {:ok, %Req.Response{status: 200, body: %{"id" => machine_id, "region" => region, "state" => state}}} ->
        status_map = %{
          status: state,
          region: region,
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }
        {:ok, %{requestor_id: id, machine_id: machine_id, status_map: status_map}}

      {:error, stuff} -> {:error, %{requestor_id: id, stuff: stuff}}

      other -> Logger.info("create_machine returned unanticipated response #{inspect other}")
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
