defmodule WhereMachines.FlyApi do

@moduledoc """
Functions to do Machines API calls using the FlyMachines library.
The default config (see config.exs) for that lib uses a FLY_API_TOKEN
environment variable  -- for local dev do
`export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)`
to get a deploy token for one app.
"""
require Logger

@doc """
List apps in personal org
"""
  def list_apps do
    FlyMachines.app_list("personal")
  end

@doc """
Run a new Machine
"""
def create_machine(appname, %FlyApi.CreateMachineRequest{} = body) do
  # def create_machine(appname, params \\ %{}) do
    # Need to validate the params. They have to be a map or struct, and I think
    # config must be required!
    if validate_struct(body, FlyApi.CreateMachineRequest) do
      {:ok, api_response} = FlyMachines.machine_create(appname, body)
      Logger.info("HEY OVER HERE #{api_response.status}")
      Logger.info("The Machine ID: #{api_response.body["id"]}")
    else
      {:error, "bad_createmachinerequest"}
    end
  end

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

  def validate_struct(struct, module) when is_struct(struct, module) do
    struct
    |> Map.from_struct()
    |> Enum.all?(fn {_, value} -> validate_value(value) end)
  end

  defp validate_value(value) when is_struct(value) do
    validate_struct_with_module(value)
  end

  defp validate_value(value) when is_list(value) do
    Enum.all?(value, &validate_value/1)
  end

  defp validate_value(_value), do: true

  # A helper to automatically pass the module of a struct
  defp validate_struct_with_module(%mod{} = struct), do: validate_struct(struct, mod)
  defp validate_struct_with_module(_), do: false

end
