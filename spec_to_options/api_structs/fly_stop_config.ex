defmodule FlyMachinesApi.FlyStopConfig do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyStopConfig"

  @enforce_keys []
  defstruct [:signal, :timeout]

  @type t :: %__MODULE__{
    signal: String.t(),
    timeout: %FlyMachinesApi.FlyDuration{},
    }
end
