defmodule FlyMachinesApi.Schemas.FlyMachineService do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :autostart, :boolean
    field :autostop, :string
    embeds_many :checks, FlyMachinesApi.Schemas.FlyMachineCheck
    embeds_one :concurrency, FlyMachinesApi.Schemas.FlyMachineServiceConcurrency
    field :force_instance_description, :string
    field :force_instance_key, :string
    field :internal_port, :integer
    field :min_machines_running, :integer
    embeds_many :ports, FlyMachinesApi.Schemas.FlyMachinePort
    field :protocol, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:autostart, :autostop, :checks, :concurrency, :force_instance_description, :force_instance_key, :internal_port, :min_machines_running, :ports, :protocol])
        |> cast_embed(:checks, with: &FlyMachinesApi.Schemas.FlyMachineCheck.changeset/2)
    |> cast_embed(:concurrency, with: &FlyMachinesApi.Schemas.FlyMachineServiceConcurrency.changeset/2)
    |> cast_embed(:ports, with: &FlyMachinesApi.Schemas.FlyMachinePort.changeset/2)
  end
end
