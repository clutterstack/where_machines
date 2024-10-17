defmodule FlyMachinesApi.FlyMachineSecret do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineSecret"

  @enforce_keys []
  defstruct [:env_var, :name]

  @type t :: %__MODULE__{
    env_var: String.t(),
    name: String.t(),
    }
end
