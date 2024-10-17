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
  def create_machine(appname, params \\ %{}) do
    # Need to validate the params. They have to be a map or struct, and I think
    # config must be required!
    {:ok, api_response} = FlyMachines.machine_create(appname, params)
    Logger.info("HEY OVER HERE #{api_response.status}")
    Logger.info("The Machine ID: #{api_response.body["id"]}")
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

end
