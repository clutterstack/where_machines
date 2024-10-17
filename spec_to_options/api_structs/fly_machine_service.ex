defmodule FlyMachinesApi.FlyMachineService do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineService"

  @enforce_keys []
  defstruct [:autostart, :autostop, :checks, :concurrency, :force_instance_description, :force_instance_key, :internal_port, :min_machines_running, :ports, :protocol]

  @type t :: %__MODULE__{
    autostart: boolean(),
    autostop: String.t(),
    checks: list(%FlyMachinesApi.FlyMachineCheck{}),
    concurrency: %FlyMachinesApi.FlyMachineServiceConcurrency{},
    force_instance_description: String.t(),
    force_instance_key: String.t(),
    internal_port: integer(),
    min_machines_running: integer(),
    ports: list(%FlyMachinesApi.FlyMachinePort{}),
    protocol: String.t(),
    }
end
