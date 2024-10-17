defmodule FlyMachinesApi.ErrorResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ErrorResponse"

  @enforce_keys []
  defstruct [:details, :error, :status]

  @type t :: %__MODULE__{
    details: any(),
    error: String.t(),
    status: %FlyMachinesApi.MainstatusCode{},
    }
end
