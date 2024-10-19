defmodule FlyMachinesApi.Schemas.MachineVersion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :user_config, {:embed, FlyMachinesApi.Schemas.FlyMachineConfig}
    field :version, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:user_config, :version])
        |> cast_embed(:user_config, with: &FlyMachinesApi.Schemas.FlyMachineConfig.changeset/2)
  end
end
