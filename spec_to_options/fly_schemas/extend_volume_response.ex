defmodule FlyMachinesApi.Schemas.ExtendVolumeResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :needs_restart, :boolean
    field :volume, {:embed, FlyMachinesApi.Schemas.Volume}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:needs_restart, :volume])
        |> cast_embed(:volume, with: &FlyMachinesApi.Schemas.Volume.changeset/2)
  end
end
