defmodule FlyMachinesApi.Organization do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Organization"

  @enforce_keys []
  defstruct [:name, :slug]

  @type t :: %__MODULE__{
    name: String.t(),
    slug: String.t(),
    }
end
