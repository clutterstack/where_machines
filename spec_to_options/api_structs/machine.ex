defmodule FlyMachinesApi.Machine do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Machine"

  @enforce_keys []
  defstruct [:checks, :config, :created_at, :events, :host_status, :id, :image_ref, :incomplete_config, :instance_id, :name, :nonce, :private_ip, :region, :state, :updated_at]

  @type t :: %__MODULE__{
    checks: list(%FlyMachinesApi.CheckStatus{}),
    config: %FlyMachinesApi.FlyMachineConfig{},
    created_at: String.t(),
    events: list(%FlyMachinesApi.MachineEvent{}),
    host_status: String.t(),
    id: String.t(),
    image_ref: %FlyMachinesApi.ImageRef{},
    incomplete_config: %FlyMachinesApi.FlyMachineConfig{},
    instance_id: String.t(),
    name: String.t(),
    nonce: String.t(),
    private_ip: String.t(),
    region: String.t(),
    state: String.t(),
    updated_at: String.t(),
    }
end
