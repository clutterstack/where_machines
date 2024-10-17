defmodule FlyMachinesApi.FlyMachineHTTPHeader do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineHTTPHeader"

  @enforce_keys []
  defstruct [:name, :values]

  @type t :: %__MODULE__{
    name: String.t(),
    values: list(String.t()),
    }
end
