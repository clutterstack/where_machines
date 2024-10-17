defmodule FlyMachinesApi.Volume do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Volume"

  @enforce_keys []
  defstruct [:attached_alloc_id, :attached_machine_id, :auto_backup_enabled, :block_size, :blocks, :blocks_avail, :blocks_free, :created_at, :encrypted, :fstype, :host_status, :id, :name, :region, :size_gb, :snapshot_retention, :state, :zone]

  @type t :: %__MODULE__{
    attached_alloc_id: String.t(),
    attached_machine_id: String.t(),
    auto_backup_enabled: boolean(),
    block_size: integer(),
    blocks: integer(),
    blocks_avail: integer(),
    blocks_free: integer(),
    created_at: String.t(),
    encrypted: boolean(),
    fstype: String.t(),
    host_status: String.t(),
    id: String.t(),
    name: String.t(),
    region: String.t(),
    size_gb: integer(),
    snapshot_retention: integer(),
    state: String.t(),
    zone: String.t(),
    }
end
