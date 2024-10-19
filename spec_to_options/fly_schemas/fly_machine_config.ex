defmodule FlyMachinesApi.Schemas.FlyMachineConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :auto_destroy, :boolean
    field :checks, :string
    field :disable_machine_autostart, :boolean
    embeds_one :dns, FlyMachinesApi.Schemas.FlyDNSConfig
    field :env, :string
    embeds_many :files, FlyMachinesApi.Schemas.FlyFile
    embeds_one :guest, FlyMachinesApi.Schemas.FlyMachineGuest
    field :image, :string
    embeds_one :init, FlyMachinesApi.Schemas.FlyMachineInit
    field :metadata, :string
    embeds_one :metrics, FlyMachinesApi.Schemas.FlyMachineMetrics
    embeds_many :mounts, FlyMachinesApi.Schemas.FlyMachineMount
    embeds_many :processes, FlyMachinesApi.Schemas.FlyMachineProcess
    embeds_one :restart, FlyMachinesApi.Schemas.FlyMachineRestart
    field :schedule, :string
    embeds_many :services, FlyMachinesApi.Schemas.FlyMachineService
    field :size, :string
    field :standbys, {:array, :string}
    embeds_many :statics, FlyMachinesApi.Schemas.FlyStatic
    embeds_one :stop_config, FlyMachinesApi.Schemas.FlyStopConfig
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:auto_destroy, :checks, :disable_machine_autostart, :dns, :env, :files, :guest, :image, :init, :metadata, :metrics, :mounts, :processes, :restart, :schedule, :services, :size, :standbys, :statics, :stop_config])
        |> cast_embed(:dns, with: &FlyMachinesApi.Schemas.FlyDNSConfig.changeset/2)
    |> cast_embed(:files, with: &FlyMachinesApi.Schemas.FlyFile.changeset/2)
    |> cast_embed(:guest, with: &FlyMachinesApi.Schemas.FlyMachineGuest.changeset/2)
    |> cast_embed(:init, with: &FlyMachinesApi.Schemas.FlyMachineInit.changeset/2)
    |> cast_embed(:metrics, with: &FlyMachinesApi.Schemas.FlyMachineMetrics.changeset/2)
    |> cast_embed(:mounts, with: &FlyMachinesApi.Schemas.FlyMachineMount.changeset/2)
    |> cast_embed(:processes, with: &FlyMachinesApi.Schemas.FlyMachineProcess.changeset/2)
    |> cast_embed(:restart, with: &FlyMachinesApi.Schemas.FlyMachineRestart.changeset/2)
    |> cast_embed(:services, with: &FlyMachinesApi.Schemas.FlyMachineService.changeset/2)
    |> cast_embed(:statics, with: &FlyMachinesApi.Schemas.FlyStatic.changeset/2)
    |> cast_embed(:stop_config, with: &FlyMachinesApi.Schemas.FlyStopConfig.changeset/2)
  end
end
