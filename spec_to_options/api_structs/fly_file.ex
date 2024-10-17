defmodule FlyMachinesApi.FlyFile do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyFile"

  @enforce_keys []
  defstruct [:guest_path, :mode, :raw_value, :secret_name]

  @type t :: %__MODULE__{
    guest_path: String.t(),
    mode: integer(),
    raw_value: String.t(),
    secret_name: String.t(),
    }
end
