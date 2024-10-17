defmodule FlyMachinesApi.FlyHTTPResponseOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyHTTPResponseOptions"

  @enforce_keys []
  defstruct [:headers, :pristine]

  @type t :: %__MODULE__{
    headers: any(),
    pristine: boolean(),
    }
end
