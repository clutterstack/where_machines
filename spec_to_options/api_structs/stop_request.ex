defmodule FlyMachinesApi.StopRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.StopRequest"

  @enforce_keys []
  defstruct [:signal, :timeout]

  @type t :: %__MODULE__{
    signal: String.t(),
    timeout: %FlyMachinesApi.FlyDuration{},
    }
end
