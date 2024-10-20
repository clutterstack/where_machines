defmodule FlyApi.FlyMachineSecret do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :env_var, :string
    field :name, :string
  end

  def changeset(schema, attrs) do
    schema
        |> validate_required([:env_var])
        |> cast(attrs, [:env_var, :name])
    
  end
end
