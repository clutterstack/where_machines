defmodule FlyMachinesApi.ExtendVolumeResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ExtendVolumeResponse"

  @enforce_keys []
  defstruct [:needs_restart, :volume]

  @type t :: %__MODULE__{
    needs_restart: boolean(),
    volume: %FlyMachinesApi.Volume{},
    }
end
