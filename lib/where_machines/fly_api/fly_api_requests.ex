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
  def create_machine(appname, body) do
    IO.inspect(body, label: "body")
    with {:ok, changeset} <- validate_schema(body, FlyApi.CreateMachineRequest) do
      {:ok, api_response} = FlyMachines.machine_create(appname, body)
      Logger.info("Response status: #{api_response.status}")
      Logger.info("New Machine ID: #{api_response.body["id"]}")
    else
      {:error, errors} -> Logger.info("Invalid CreateMachineRequest. #{inspect errors}")
      _ -> Logger.info("body_changeset wasn't a valid CreateMachineRequest")
    end
  end

  ## old
  # def validate_schema(body, schema_module_name) do
  #   changeset = schema_module_name.changeset(struct(schema_module_name), body)
  #   if changeset.valid? do
  #     IO.puts("Map matches the schema!")
  #     true
  #   else
  #     IO.puts("Map does not match the schema.")
  #     IO.inspect(Ecto.Changeset.traverse_errors(changeset, &(&1)), label: "traversing changeset errors")
  #     false
  #   end
  # end

  def validate_schema(body, schema_module_name) do
    changeset = schema_module_name.changeset(struct(schema_module_name), body)

    case changeset.valid? do
      true ->
        {:ok, changeset}
      false ->
        {:error, Ecto.Changeset.traverse_errors(changeset, &(&1))}
    end
  end

  # def validate_req_body(body) do
  #   IO.inspect(body, label: "inside validate_req_body; body")
  #   changeset = FlyApi.CreateMachineRequest.changeset(%FlyApi.CreateMachineRequest{}, body)
  #   if changeset.valid? do
  #     IO.puts("Map matches the schema!")
  #     true
  #   else
  #     IO.puts("Map does not match the schema.")
  #     IO.inspect(Ecto.Changeset.traverse_errors(changeset, &(&1)), label: "traversing changeset errors")
  #     false
  #   end
  # end


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

@doc """
Try running with a bad type in config
"""
def run_bad_type do
  appname = "where"
  mach_params = %{
    config: %{
      auto_destroy: "yes", # this should be boolean,
      image: "registry.fly.io/where:debian-nano"
    },
  }
  create_machine(appname, mach_params)
end

@doc """
Try running with the image missing
"""
def run_missing_image do
  appname = "where"
  mach_params = %{
    config: %{
      auto_destroy: true, # this should be boolean,
    },
  }
  create_machine(appname, mach_params)
end

  @doc """
  Try running with an extra field.
  This should work fine; ecto just ignores extra fields:
  """
  def run_extra_fields do
    appname = "where"
    mach_params = %{
      floog: %{
        stuff: 1585
      },
      config: %{
        norf: "glagl",
        image: "registry.fly.io/where:debian-nano"
      }
    }
    body = struct(FlyApi.CreateMachineRequest, mach_params)
    # encoded_params = Jason.encode!(mach_params)
    create_machine(appname, body)
  end

end
