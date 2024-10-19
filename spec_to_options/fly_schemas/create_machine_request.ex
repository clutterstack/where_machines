defmodule FlyMachinesApi.Schemas.CreateMachineRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :config, {:embed, FlyMachinesApi.Schemas.FlyMachineConfig}
    field :lease_ttl, :integer
    field :lsvd, :boolean
    field :name, :string
    field :region, :string
    field :skip_launch, :boolean
    field :skip_service_registration, :boolean
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:config, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration])
        |> cast_embed(:config, with: &FlyMachinesApi.Schemas.FlyMachineConfig.changeset/2)
  end
end
