defmodule FlyMachinesApi.UpdateMachineRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.UpdateMachineRequest"

  @enforce_keys []
  defstruct [:config, :current_version, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration]

  @type t :: %__MODULE__{
    config: any(),
    current_version: String.t(),
    lease_ttl: integer(),
    lsvd: boolean(),
    name: String.t(),
    region: String.t(),
    skip_launch: boolean(),
    skip_service_registration: boolean(),
    }
end
