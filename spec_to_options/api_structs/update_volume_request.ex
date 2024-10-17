defmodule FlyMachinesApi.UpdateVolumeRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.UpdateVolumeRequest"

  @enforce_keys []
  defstruct [:auto_backup_enabled, :snapshot_retention]

  @type t :: %__MODULE__{
    auto_backup_enabled: boolean(),
    snapshot_retention: integer(),
    }
end
