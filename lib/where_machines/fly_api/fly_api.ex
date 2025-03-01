defmodule WhereMachines.FlyApi do

@moduledoc """
Functions to do Machines API calls using the FlyMachines library.
The default config (see config.exs) for that lib uses a FLY_API_TOKEN
environment variable  -- for local dev do
`export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)`
to get a deploy token for one app.
"""
  require Logger

  # List of operations with their schema module, required fields and API function
  # TODO: swap this for pattern matching at `execute_api_call/3`
  @operations %{
    create_machine: %{
      schema_module: FlyApi.CreateMachineRequest,
      api_function: &FlyMachines.machine_create/2
    },
    update_machine: %{
      schema_module: FlyApi.UpdateMachineRequest,
      api_function: &FlyMachines.machine_update/3
    },
    create_volume: %{
      schema_module: FlyApi.CreateVolumeRequest,
      api_function: &FlyMachines.volume_create/2
    },
    update_volume: %{
      schema_module: FlyApi.UpdateVolumeRequest,
      api_function: &FlyMachines.volume_update/3
    }
  }

  @doc """
  List apps in personal org
  """
    def list_apps do
      FlyMachines.app_list("personal")
    end

  @doc """
  Generic function to validate and execute API calls
  """
  def execute_api_call(operation, args, params) when is_atom(operation) and is_map(params) do
    case Map.get(@operations, operation) do
      nil ->
        {:error, {:unknown_operation, operation}}

      %{schema_module: schema_module, api_function: api_function} ->
        with {:ok, valid_params} <- validate_params(params, schema_module),
              {:ok, response} <- apply_api_function(api_function, args ++ [valid_params]) do
          result = response.body
          Logger.info("#{operation} successful")
          {:ok, result}
        end
    end
  end

  # Convenience functions for common operations

  @doc """
  Run a new Machine
  """
  def create_machine(appname, params), do: execute_api_call(:create_machine, [appname], params)

  @doc """
  Change the Machine's config (causes a restart)
  """
  def update_machine(appname, machine_id, params), do: execute_api_call(:update_machine, [appname, machine_id], params)
  @doc """
  Create a new volume
  """
  def create_volume(appname, params), do: execute_api_call(:create_volume, [appname], params)
  @doc """
  Update a volume
  """
  def update_volume(appname, volume_id, params), do: execute_api_call(:update_volume, [appname, volume_id], params)



  @doc """
  Try running with a preset config:
  """
    def run_preset_machine do
      appname = "where"
      mach_params = %{
        config: %{
          image: "registry.fly.io/where:debian-nano",
          auto_destroy: true,
          guest: %{
            cpu_kind: "shared",
            cpus: 1,
            memory_mb: 256
          }
        }
      }
      create_machine(appname, mach_params)
    end


    @doc """
    Try running with a preset config:
    """
    def run_min_config do
      appname = "where"
      mach_params = %{
        config: %{
          image: "registry.fly.io/where:debian-nano"
        }
      }
      create_machine(appname, mach_params)
    end
# Private Functions

  # Validates parameters using the provided schema module
  defp validate_params(params, schema_module) do
    changeset = schema_module.changeset(struct(schema_module), params)

    if changeset.valid? do
      # Convert to a map removing any nil values for the API call
      valid_params =
        changeset
        |> Ecto.Changeset.apply_changes()
        |> Map.from_struct()
        |> cleanup_map()

      {:ok, valid_params}
    else
      errors = format_changeset_errors(changeset)
      Logger.error("Invalid params for #{inspect(schema_module)}: #{inspect(errors)}")
      {:error, {:invalid_params, errors}}
    end
  end

  # Apply the API function with the given arguments and handle errors
  defp apply_api_function(api_function, args) do
    try do
      case apply(api_function, args) do
        {:ok, response} -> {:ok, response}
        {:error, error} ->
          Logger.error("API error: #{inspect(error)}")
          {:error, {:api_error, error}}
      end
    rescue
      e ->
        Logger.error("Exception calling API: #{inspect(e)}")
        {:error, {:exception, e}}
    end
  end

  # Recursively cleans map by removing nil values and empty maps
  # Convert a struct to a map first so we can use Enum functions

  defp cleanup_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> cleanup_map()
  end

  defp cleanup_map(map) when is_map(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.map(fn {k, v} -> {k, cleanup_value(v)} end)
    |> Enum.into(%{})
    |> reject_empty_maps()
  end

  defp cleanup_value(value) when is_map(value), do: cleanup_map(value)
  defp cleanup_value(value) when is_list(value), do: Enum.map(value, &cleanup_value/1)
  defp cleanup_value(value), do: value

  defp reject_empty_maps(map) when map == %{}, do: nil
  defp reject_empty_maps(map), do: map

  # Formats changeset errors into a human-readable format
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
