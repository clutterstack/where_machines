defmodule FlyMachinesApi.Schemas.FlyMachineProcess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :cmd, {:array, :string}
    field :entrypoint, {:array, :string}
    field :env, :string
    embeds_many :env_from, FlyMachinesApi.Schemas.FlyEnvFrom
    field :exec, {:array, :string}
    field :ignore_app_secrets, :boolean
    embeds_many :secrets, FlyMachinesApi.Schemas.FlyMachineSecret
    field :user, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:cmd, :entrypoint, :env, :env_from, :exec, :ignore_app_secrets, :secrets, :user])
        |> cast_embed(:env_from, with: &FlyMachinesApi.Schemas.FlyEnvFrom.changeset/2)
    |> cast_embed(:secrets, with: &FlyMachinesApi.Schemas.FlyMachineSecret.changeset/2)
  end
end
