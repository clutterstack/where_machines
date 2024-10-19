defmodule FlyMachinesApi.Schemas.FlyMachinePort do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :end_port, :integer
    field :force_https, :boolean
    field :handlers, {:array, :string}
    field :http_options, {:embed, FlyMachinesApi.Schemas.FlyHTTPOptions}
    field :port, :integer
    field :proxy_proto_options, {:embed, FlyMachinesApi.Schemas.FlyProxyProtoOptions}
    field :start_port, :integer
    field :tls_options, {:embed, FlyMachinesApi.Schemas.FlyTLSOptions}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:end_port, :force_https, :handlers, :http_options, :port, :proxy_proto_options, :start_port, :tls_options])
        |> cast_embed(:http_options, with: &FlyMachinesApi.Schemas.FlyHTTPOptions.changeset/2)
    |> cast_embed(:proxy_proto_options, with: &FlyMachinesApi.Schemas.FlyProxyProtoOptions.changeset/2)
    |> cast_embed(:tls_options, with: &FlyMachinesApi.Schemas.FlyTLSOptions.changeset/2)
  end
end
