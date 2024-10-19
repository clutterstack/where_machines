defmodule FlyMachinesApi.Schemas.FlyDNSConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :dns_forward_rules, {:array, {:embed, FlyMachinesApi.Schemas.FlyDnsForwardRule}}
    field :hostname, :string
    field :hostname_fqdn, :string
    field :nameservers, {:array, :string}
    field :options, {:array, {:embed, FlyMachinesApi.Schemas.FlyDnsOption}}
    field :searches, {:array, :string}
    field :skip_registration, :boolean
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:dns_forward_rules, :hostname, :hostname_fqdn, :nameservers, :options, :searches, :skip_registration])
        |> cast_embed(:dns_forward_rules, with: &FlyMachinesApi.Schemas.FlyDnsForwardRule.changeset/2)
    |> cast_embed(:options, with: &FlyMachinesApi.Schemas.FlyDnsOption.changeset/2)
  end
end
