defmodule WhereMachines.PresetCommands do
  require Logger
  alias WhereMachines.FlyApi

  # Convenience functions for common operations
  # TODO: these should generally do more than call the API.
  # API calls are provided by the fly_machines package
  # Validating and calling is already handled by validate_and_run()
  # So here is a place to build in things like waits or even deployment
  # Like flyctl commands but with personalised opinions

  @doc """
  List apps in personal org
  """
  def list_apps do
    FlyMachines.app_list("personal")
  end

  @doc """
  Run a new Machine
  """
  def machine_create(appname, body), do: validate_and_run(:machine_create, [appname], body)

  @doc """
  Change the Machine's config (causes a restart)
  """
  def update_machine(appname, machine_id, body), do: validate_and_run(:update_machine, [appname, machine_id], body)

  @doc """
  Create a new volume
  """
  def create_volume(appname, body), do: validate_and_run(:create_volume, [appname], body)
  @doc """
  Update a volume
  """
  def update_volume(appname, volume_id, body), do: validate_and_run(:update_volume, [appname, volume_id], body)


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
      machine_create(appname, mach_params)
    end

    @doc """
    Run with a minimal preset config:
    """
    def run_min_config do
      appname = "where"
      mach_params = %{
        config: %{
          image: "registry.fly.io/where:debian-nano"
        }
      }
      machine_create(appname, mach_params)
    end

end
