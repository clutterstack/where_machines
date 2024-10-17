defmodule FlyMachinesApi.FlyDNSConfig do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyDNSConfig"

  @enforce_keys []
  defstruct [:dns_forward_rules, :hostname, :hostname_fqdn, :nameservers, :options, :searches, :skip_registration]

  @type t :: %__MODULE__{
    dns_forward_rules: list(%FlyMachinesApi.FlydnsForwardRule{}),
    hostname: String.t(),
    hostname_fqdn: String.t(),
    nameservers: list(String.t()),
    options: list(%FlyMachinesApi.FlydnsOption{}),
    searches: list(String.t()),
    skip_registration: boolean(),
    }
end
