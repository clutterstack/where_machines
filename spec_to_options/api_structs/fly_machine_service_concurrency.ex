defmodule FlyMachinesApi.FlyMachineServiceConcurrency do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineServiceConcurrency"

  @enforce_keys []
  defstruct [:hard_limit, :soft_limit, :type]

  @type t :: %__MODULE__{
    hard_limit: integer(),
    soft_limit: integer(),
    type: String.t(),
    }
end
