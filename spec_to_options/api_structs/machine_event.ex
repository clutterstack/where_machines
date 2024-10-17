defmodule FlyMachinesApi.MachineEvent do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineEvent"

  @enforce_keys []
  defstruct [:id, :request, :source, :status, :timestamp, :type]

  @type t :: %__MODULE__{
    id: String.t(),
    request: any(),
    source: String.t(),
    status: String.t(),
    timestamp: integer(),
    type: String.t(),
    }
end
