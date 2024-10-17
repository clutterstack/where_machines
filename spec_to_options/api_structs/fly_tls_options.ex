defmodule FlyMachinesApi.FlyTLSOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyTLSOptions"

  @enforce_keys []
  defstruct [:alpn, :default_self_signed, :versions]

  @type t :: %__MODULE__{
    alpn: list(String.t()),
    default_self_signed: boolean(),
    versions: list(String.t()),
    }
end
