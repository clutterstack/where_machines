defmodule FlyMachinesApi.Schemas.FlyMachineCheck do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one :grace_period, FlyMachinesApi.Schemas.FlyDuration
    field :headers, {:array, FlyMachinesApi.Schemas.FlyMachineHTTPHeader}
    embeds_one :interval, FlyMachinesApi.Schemas.FlyDuration
    field :kind, :string
    field :method, :string
    field :path, :string
    field :port, :integer
    field :protocol, :string
    embeds_one :timeout, FlyMachinesApi.Schemas.FlyDuration
    field :tls_server_name, :string
    field :tls_skip_verify, :boolean
    field :type, :string
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:grace_period, :headers, :interval, :kind, :method, :path, :port, :protocol, :timeout, :tls_server_name, :tls_skip_verify, :type])
        |> cast_embed(:grace_period, with: &FlyMachinesApi.Schemas.FlyDuration.changeset/2)
    |> cast_embed(:headers, with: &FlyMachinesApi.Schemas.FlyMachineHTTPHeader.changeset/2)
    |> cast_embed(:interval, with: &FlyMachinesApi.Schemas.FlyDuration.changeset/2)
    |> cast_embed(:timeout, with: &FlyMachinesApi.Schemas.FlyDuration.changeset/2)
  end
end
