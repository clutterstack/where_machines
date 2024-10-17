defmodule FlyMachinesApi.FlyMachineGuest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineGuest"

  @enforce_keys []
  defstruct [:cpu_kind, :cpus, :gpu_kind, :gpus, :host_dedication_id, :kernel_args, :memory_mb]

  @type t :: %__MODULE__{
    cpu_kind: String.t(),
    cpus: integer(),
    gpu_kind: String.t(),
    gpus: integer(),
    host_dedication_id: String.t(),
    kernel_args: list(String.t()),
    memory_mb: integer(),
    }
end
