defmodule FlyMachinesApi.CreateAppRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateAppRequest"

  @enforce_keys []
  defstruct [:app_name, :enable_subdomains, :network, :org_slug]

  @type t :: %__MODULE__{
    app_name: String.t(),
    enable_subdomains: boolean(),
    network: String.t(),
    org_slug: String.t(),
    }
end
