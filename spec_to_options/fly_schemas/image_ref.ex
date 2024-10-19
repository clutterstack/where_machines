defmodule FlyMachinesApi.Schemas.ImageRef do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :digest, :string
    field :labels, :string
    field :registry, :string
    field :repository, :string
    field :tag, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:digest, :labels, :registry, :repository, :tag])
    
  end
end
