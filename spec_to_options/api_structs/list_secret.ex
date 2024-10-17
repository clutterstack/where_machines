defmodule FlyMachinesApi.ListSecret do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListSecret"

  @enforce_keys []
  defstruct [:label, :publickey, :type]

  @type t :: %__MODULE__{
    label: String.t(),
    publickey: list(integer()),
    type: String.t(),
    }
end
