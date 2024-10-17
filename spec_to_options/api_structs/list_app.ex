defmodule FlyMachinesApi.ListApp do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListApp"

  @enforce_keys []
  defstruct [:id, :machine_count, :name, :network]

  @type t :: %__MODULE__{
    id: String.t(),
    machine_count: integer(),
    name: String.t(),
    network: any(),
    }
end
