defmodule FlyMachinesApi.MachineVersion do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineVersion"

  @enforce_keys []
  defstruct [:user_config, :version]

  @type t :: %__MODULE__{
    user_config: %FlyMachinesApi.FlyMachineConfig{},
    version: String.t(),
    }
end
