defmodule FlyMachinesApi.ListenSocket do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListenSocket"

  @enforce_keys []
  defstruct [:address, :proto]

  @type t :: %__MODULE__{
    address: String.t(),
    proto: String.t(),
    }
end
