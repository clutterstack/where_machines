defmodule FlyMachinesApi.Schemas.FlyMachineConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :auto_destroy, :boolean
    field :checks, {:embed, UnknownSchema}
    field :disable_machine_autostart, :boolean
    field :dns, {:embed, FlyMachinesApi.Schemas.FlyDNSConfig}
    field :env, {:embed, UnknownSchema}
    field :files, {:array, {:embed, FlyMachinesApi.Schemas.FlyFile}}
    field :guest, {:embed, FlyMachinesApi.Schemas.FlyMachineGuest}
    field :image, :string
    field :init, {:embed, FlyMachinesApi.Schemas.FlyMachineInit}
    field :metadata, {:embed, UnknownSchema}
    field :metrics, {:embed, FlyMachinesApi.Schemas.FlyMachineMetrics}
    field :mounts, {:array, {:embed, FlyMachinesApi.Schemas.FlyMachineMount}}
    field :processes, {:array, {:embed, FlyMachinesApi.Schemas.FlyMachineProcess}}
    field :restart, {:embed, FlyMachinesApi.Schemas.FlyMachineRestart}
    field :schedule, :string
    field :services, {:array, {:embed, FlyMachinesApi.Schemas.FlyMachineService}}
    field :size, :string
    field :standbys, {:array, :string}
    field :statics, {:array, {:embed, FlyMachinesApi.Schemas.FlyStatic}}
    field :stop_config, {:embed, FlyMachinesApi.Schemas.FlyStopConfig}
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
