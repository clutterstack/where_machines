defmodule FlyMachinesApi.Flydv1ExecResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Flydv1ExecResponse"

  @enforce_keys []
  defstruct [:exit_code, :exit_signal, :stderr, :stdout]

  @type t :: %__MODULE__{
    exit_code: integer(),
    exit_signal: integer(),
    stderr: String.t(),
    stdout: String.t(),
    }
end
