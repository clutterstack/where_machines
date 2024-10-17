defmodule FlyMachinesApi.VolumeSnapshot do
  @moduledoc "Automatically generated struct for FlyMachinesApi.VolumeSnapshot"

  @enforce_keys []
  defstruct [:created_at, :digest, :id, :retention_days, :size, :status]

  @type t :: %__MODULE__{
    created_at: String.t(),
    digest: String.t(),
    id: String.t(),
    retention_days: integer(),
    size: integer(),
    status: String.t(),
    }
end
