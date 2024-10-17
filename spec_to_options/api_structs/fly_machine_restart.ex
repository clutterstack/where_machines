defmodule FlyMachinesApi.FlyMachineRestart do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineRestart"

  @enforce_keys []
  defstruct [:gpu_bid_price, :max_retries, :policy]

  @type t :: %__MODULE__{
    gpu_bid_price: any(),
    max_retries: integer(),
    policy: String.t(),
    }
end
