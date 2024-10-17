defmodule FlyMachinesApi.CreateVolumeRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateVolumeRequest"

  @enforce_keys []
  defstruct [:compute, :compute_image, :encrypted, :fstype, :name, :region, :require_unique_zone, :size_gb, :snapshot_id, :snapshot_retention, :source_volume_id]

  @type t :: %__MODULE__{
    compute: %FlyMachinesApi.FlyMachineGuest{},
    compute_image: String.t(),
    encrypted: boolean(),
    fstype: String.t(),
    name: String.t(),
    region: String.t(),
    require_unique_zone: boolean(),
    size_gb: integer(),
    snapshot_id: String.t(),
    snapshot_retention: integer(),
    source_volume_id: String.t(),
    }
end
