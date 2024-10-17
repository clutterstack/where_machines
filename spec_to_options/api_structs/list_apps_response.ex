defmodule FlyMachinesApi.ListAppsResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListAppsResponse"

  @enforce_keys []
  defstruct [:apps, :total_apps]

  @type t :: %__MODULE__{
    apps: list(%FlyMachinesApi.ListApp{}),
    total_apps: integer(),
    }
end
