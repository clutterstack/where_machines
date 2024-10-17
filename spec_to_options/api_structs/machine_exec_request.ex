defmodule FlyMachinesApi.MachineExecRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineExecRequest"

  @enforce_keys []
  defstruct [:cmd, :command, :timeout]

  @type t :: %__MODULE__{
    cmd: String.t(),
    command: list(String.t()),
    timeout: integer(),
    }
end
