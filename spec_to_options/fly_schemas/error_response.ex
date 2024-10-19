defmodule FlyMachinesApi.Schemas.ErrorResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :details, {:embed, UnknownSchema}
    field :error, :string
    field :status, {:embed, FlyMachinesApi.Schemas.MainStatusCode}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:details, :error, :status])
        |> cast_embed(:status, with: &FlyMachinesApi.Schemas.MainStatusCode.changeset/2)
  end
end
