defmodule FlyMachinesApi.FlyMachineInit do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineInit"

  @enforce_keys []
  defstruct [:cmd, :entrypoint, :exec, :kernel_args, :swap_size_mb, :tty]

  @type t :: %__MODULE__{
    cmd: list(String.t()),
    entrypoint: list(String.t()),
    exec: list(String.t()),
    kernel_args: list(String.t()),
    swap_size_mb: integer(),
    tty: boolean(),
    }
end
