defmodule FlyMachinesApi.Schemas.ListApp do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :string
    field :machine_count, :integer
    field :name, :string
    field :network, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:id, :machine_count, :name, :network])
    
  end
end
