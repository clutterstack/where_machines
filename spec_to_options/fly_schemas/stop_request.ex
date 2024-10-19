defmodule FlyMachinesApi.Schemas.StopRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :signal, :string
    field :timeout, {:embed, FlyMachinesApi.Schemas.FlyDuration}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:signal, :timeout])
        |> cast_embed(:timeout, with: &FlyMachinesApi.Schemas.FlyDuration.changeset/2)
  end
end
