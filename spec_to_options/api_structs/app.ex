defmodule FlyMachinesApi.App do
  @moduledoc "Automatically generated struct for FlyMachinesApi.App"

  @enforce_keys []
  defstruct [:id, :name, :organization, :status]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    organization: %FlyMachinesApi.Organization{},
    status: String.t(),
    }
end
