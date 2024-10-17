defmodule FlyMachinesApi.FlyMachineMount do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineMount"

  @enforce_keys []
  defstruct [:add_size_gb, :encrypted, :extend_threshold_percent, :name, :path, :size_gb, :size_gb_limit, :volume]

  @type t :: %__MODULE__{
    add_size_gb: integer(),
    encrypted: boolean(),
    extend_threshold_percent: integer(),
    name: String.t(),
    path: String.t(),
    size_gb: integer(),
    size_gb_limit: integer(),
    volume: String.t(),
    }
end
