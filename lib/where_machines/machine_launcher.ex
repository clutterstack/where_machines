defmodule WhereMachines.MachineLauncher do

  require Logger
  alias WhereMachines.MachineTracker
  import WhereMachines.MachineParams

  @mach_limit 8
  @app_name "useless-machine"

  def maybe_spawn_useless_machine(id, region \\ "", start_time \\ nil) do
    region = validate_region(region)
    # If tracker says we have capacity, verify with ETS if fresh or API if not
    case MachineTracker.get_fresh_count() do

      {:ok, api_count, _} -> Logger.debug("MachineLauncher got count #{api_count} from tracker")
          if api_count < @mach_limit do
            Logger.debug("Tracker says we're below our limit; creating a new Machine")
            spawn_machine(id, region, start_time)
          else
            Logger.info("Machine limit reached; not creating a new one.")
            {:error, %{requestor_id: id, reason: :capacity, message: "Reached capacity; try again later."}}
          end

      {:timeout, stuff} ->
        Logger.debug("the genserver timed out: #{inspect stuff}")
        {:error, %{requestor_id: id, reason: :genserver_timeout, stuff: stuff}}
    end

  end

  defp spawn_machine(id, requested_region, start_time) do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("USELESS_API_TOKEN"))

    # Determine source based on id
    source = if id == "auto-spawner", do: :auto, else: :manual

    # Calculate elapsed time and add to params
    elapsed_str = if start_time, do: "#{System.system_time(:millisecond) - start_time}ms", else: "unknown"

    machine_params = useless_params(source)
                    |> put_in([:config, :env, "MACHINE_START_TIME"], elapsed_str)

    case Clutterfly.FlyAPI.create_machine(client, @app_name, Enum.into(%{region: requested_region}, machine_params)) do
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

  # {:ok, %Req.Response{status: 200, headers: %{"content-type" => ["application/json; charset=utf-8"], "date" => ["Tue, 22 Apr 2025 04:43:11 GMT"], "fly-request-id" => ["01JSDWX4XJWBVWKTPVV5KBQSEC-yyz"], "fly-span-id" => ["9b3f701a6c0f955e"], "fly-trace-id" => ["73dd28b095d55024c09633a2098c19a9"], "server" => ["Fly/9c00af92e (2025-04-17)"], "transfer-encoding" => ["chunked"], "via" => ["1.1 fly.io"], "x-envoy-upstream-service-time" => ["4861"]}, body: %{"ok" => true}, trailers: %{}, private: %{}}}
  def wait_for_machine_to_start(id) do
    client = Clutterfly.FlyAPI.new(receive_timeout: 30_000, api_token: System.get_env("USELESS_API_TOKEN"))
    case Clutterfly.FlyAPI.wait_for_machine(client, @app_name, id) do
      {:ok, %Req.Response{status: 200}} ->
        Logger.debug("wait_for_machine API call received OK 200")
        {:ok, %{machine_id: id, status: :started}}

      {:error, stuff} -> Logger.error("Waiting for Machine #{id} to start, got an error from the API: #{inspect stuff}")
        {:error, %{stuff: stuff}}


      other -> Logger.warning("wait_for_machine_to_start/1 returned unanticipated response #{inspect other}")
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
