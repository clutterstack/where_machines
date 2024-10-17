defmodule FlyMachinesApi.CreateLeaseRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateLeaseRequest"

  @enforce_keys []
  defstruct [:description, :ttl]

  @type t :: %__MODULE__{
    description: String.t(),
    ttl: integer(),
    }
end
