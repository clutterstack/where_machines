defmodule FlyMachinesApi.FlyMachineCheck do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineCheck"

  @enforce_keys []
  defstruct [:grace_period, :headers, :interval, :kind, :method, :path, :port, :protocol, :timeout, :tls_server_name, :tls_skip_verify, :type]

  @type t :: %__MODULE__{
    grace_period: any(),
    headers: list(%FlyMachinesApi.FlyMachineHTTPHeader{}),
    interval: any(),
    kind: String.t(),
    method: String.t(),
    path: String.t(),
    port: integer(),
    protocol: String.t(),
    timeout: any(),
    tls_server_name: String.t(),
    tls_skip_verify: boolean(),
    type: String.t(),
    }
end
