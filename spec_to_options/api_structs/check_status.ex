defmodule FlyMachinesApi.CheckStatus do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CheckStatus"

  @enforce_keys []
  defstruct [:name, :output, :status, :updated_at]

  @type t :: %__MODULE__{
    name: String.t(),
    output: String.t(),
    status: String.t(),
    updated_at: String.t(),
    }
end
