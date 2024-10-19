defmodule FlyMachinesApi.Schemas.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :checks, {:array, {:embed, FlyMachinesApi.Schemas.CheckStatus}}
    field :config, {:embed, FlyMachinesApi.Schemas.FlyMachineConfig}
    field :created_at, :string
    field :events, {:array, {:embed, FlyMachinesApi.Schemas.MachineEvent}}
    field :host_status, :string
    field :id, :string
    field :image_ref, {:embed, FlyMachinesApi.Schemas.ImageRef}
    field :incomplete_config, {:embed, FlyMachinesApi.Schemas.FlyMachineConfig}
    field :instance_id, :string
    field :name, :string
    field :nonce, :string
    field :private_ip, :string
    field :region, :string
    field :state, :string
    field :updated_at, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:checks, :config, :created_at, :events, :host_status, :id, :image_ref, :incomplete_config, :instance_id, :name, :nonce, :private_ip, :region, :state, :updated_at])
        |> cast_embed(:checks, with: &FlyMachinesApi.Schemas.CheckStatus.changeset/2)
    |> cast_embed(:config, with: &FlyMachinesApi.Schemas.FlyMachineConfig.changeset/2)
    |> cast_embed(:events, with: &FlyMachinesApi.Schemas.MachineEvent.changeset/2)
    |> cast_embed(:image_ref, with: &FlyMachinesApi.Schemas.ImageRef.changeset/2)
    |> cast_embed(:incomplete_config, with: &FlyMachinesApi.Schemas.FlyMachineConfig.changeset/2)
  end
end
