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
  def create_machine(appname, json_body \\ %{}) do
    IO.inspect(json_body, label: "json_body")
    # Need to validate the params. They have to be a map or struct, and I think
    # config must be required!
    decoded_body = Jason.decode!(json_body) |> IO.inspect(label: "argh")
    body_changeset = FlyApi.CreateMachineRequest.changeset(%FlyApi.CreateMachineRequest{}, decoded_body)
    |> IO.inspect(label: "body_changeset")
    if body_changeset.valid? do
      # Valid JSON data; send the request
      {:ok, api_response} = FlyMachines.machine_create(appname, json_body)
      Logger.info("HEY OVER HERE #{api_response.status}")
      Logger.info("The Machine ID: #{api_response.body["id"]}")
    else
      # Handle errors
      Logger.info("body_changeset wasn't a valid CreateMachineRequest")
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
  encoded_params = Jason.encode!(mach_params)
  create_machine(appname, encoded_params)
end

end
