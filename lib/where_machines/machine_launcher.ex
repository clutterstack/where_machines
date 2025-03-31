defmodule WhereMachines.MachineLauncher do

  require Logger
  alias WhereMachines.MachineTracker
  import WhereMachines.MachineParams

  @mach_limit 3
  @app_name "useless-machine"

  def maybe_spawn_useless_machine(client) do
    # First check tracker (fast)
    {count, _regions, _} = MachineTracker.region_stats()

    if count < @mach_limit do
      Logger.info("Local tracker indicates capacity; check with API and try to launch a new Machine")

      # If tracker says we have capacity, verify with API (accurate)
      case Clutterfly.Commands.get_mach_summaries(@app_name, client: client) do
        {:ok, api_machines} ->
          MachineTracker.update_all_from_api(api_machines)
          # Count running machines from API
          api_count = Enum.count(api_machines)

          if api_count < @mach_limit do
            Logger.info("API says we have capacity; creating a new Machine")
            Clutterfly.FlyAPI.create_machine(client, @app_name, useless_params())
          else
            Logger.info("API check shows no capacity; not creating a new Machine")
            {:error, %{reason: :capacity, message: "At capacity; try again later"}}
          end

        {:error, reason} ->
          # API check failed, fall back to tracker data
          Logger.warning("API check failed: #{inspect(reason)}. Falling back to tracker data.")
            Clutterfly.FlyAPI.create_machine(client, @app_name, useless_params())
      end
    else
      Logger.info("Machine limit reached; not creating a new one.")
      {:error, %{reason: :capacity, message: "Reached capacity; try again later."}}
    end
  end


end
