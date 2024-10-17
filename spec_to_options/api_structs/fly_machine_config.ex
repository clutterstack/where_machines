defmodule FlyMachinesApi.FlyMachineConfig do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineConfig"

  @enforce_keys []
  defstruct [:auto_destroy, :checks, :disable_machine_autostart, :dns, :env, :files, :guest, :image, :init, :metadata, :metrics, :mounts, :processes, :restart, :schedule, :services, :size, :standbys, :statics, :stop_config]

  @type t :: %__MODULE__{
    auto_destroy: boolean(),
    checks: any(),
    disable_machine_autostart: boolean(),
    dns: %FlyMachinesApi.FlyDNSConfig{},
    env: any(),
    files: list(%FlyMachinesApi.FlyFile{}),
    guest: %FlyMachinesApi.FlyMachineGuest{},
    image: String.t(),
    init: %FlyMachinesApi.FlyMachineInit{},
    metadata: any(),
    metrics: %FlyMachinesApi.FlyMachineMetrics{},
    mounts: list(%FlyMachinesApi.FlyMachineMount{}),
    processes: list(%FlyMachinesApi.FlyMachineProcess{}),
    restart: %FlyMachinesApi.FlyMachineRestart{},
    schedule: String.t(),
    services: list(%FlyMachinesApi.FlyMachineService{}),
    size: String.t(),
    standbys: list(String.t()),
    statics: list(%FlyMachinesApi.FlyStatic{}),
    stop_config: %FlyMachinesApi.FlyStopConfig{},
    }
end
