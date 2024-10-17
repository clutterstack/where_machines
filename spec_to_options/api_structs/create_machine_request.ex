defmodule FlyMachinesApi.CreateMachineRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateMachineRequest"

  @enforce_keys []
  defstruct [:config, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration]

  @type t :: %__MODULE__{
    config: any(),
    lease_ttl: integer(),
    lsvd: boolean(),
    name: String.t(),
    region: String.t(),
    skip_launch: boolean(),
    skip_service_registration: boolean(),
    }
end
