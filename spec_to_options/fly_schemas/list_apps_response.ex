defmodule FlyMachinesApi.Schemas.ListAppsResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :apps, {:array, {:embed, FlyMachinesApi.Schemas.ListApp}}
    field :total_apps, :integer
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:apps, :total_apps])
        |> cast_embed(:apps, with: &FlyMachinesApi.Schemas.ListApp.changeset/2)
  end
end
