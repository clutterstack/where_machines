defmodule FlyMachinesApi.FlyMachinePort do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachinePort"

  @enforce_keys []
  defstruct [:end_port, :force_https, :handlers, :http_options, :port, :proxy_proto_options, :start_port, :tls_options]

  @type t :: %__MODULE__{
    end_port: integer(),
    force_https: boolean(),
    handlers: list(String.t()),
    http_options: %FlyMachinesApi.FlyHTTPOptions{},
    port: integer(),
    proxy_proto_options: %FlyMachinesApi.FlyProxyProtoOptions{},
    start_port: integer(),
    tls_options: %FlyMachinesApi.FlyTLSOptions{},
    }
end
