defmodule FlyMachinesApi.Schemas.FlyHTTPResponseOptions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :headers, :any
    field :pristine, :boolean
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:headers, :pristine])
    
  end
end
