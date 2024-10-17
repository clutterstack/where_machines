defmodule FlyMachinesApi.FlyEnvFrom do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyEnvFrom"

  @enforce_keys []
  defstruct [:env_var, :field_ref]

  @type t :: %__MODULE__{
    env_var: String.t(),
    field_ref: String.t(),
    }
end
