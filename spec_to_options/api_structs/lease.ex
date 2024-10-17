defmodule FlyMachinesApi.Lease do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Lease"

  @enforce_keys []
  defstruct [:description, :expires_at, :nonce, :owner, :version]

  @type t :: %__MODULE__{
    description: String.t(),
    expires_at: integer(),
    nonce: String.t(),
    owner: String.t(),
    version: String.t(),
    }
end
