defmodule FlyMachinesApi.FlyMachineProcess do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineProcess"

  @enforce_keys []
  defstruct [:cmd, :entrypoint, :env, :env_from, :exec, :ignore_app_secrets, :secrets, :user]

  @type t :: %__MODULE__{
    cmd: list(String.t()),
    entrypoint: list(String.t()),
    env: any(),
    env_from: list(%FlyMachinesApi.FlyEnvFrom{}),
    exec: list(String.t()),
    ignore_app_secrets: boolean(),
    secrets: list(%FlyMachinesApi.FlyMachineSecret{}),
    user: String.t(),
    }
end
