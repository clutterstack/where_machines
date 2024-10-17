defmodule FlyMachinesApi.CheckStatus do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CheckStatus"

  @enforce_keys []
  defstruct [:name, :output, :status, :updated_at]

  @type t :: %__MODULE__{
    name: String.t(),
    output: String.t(),
    status: String.t(),
    updated_at: String.t(),
    }
end


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


defmodule FlyMachinesApi.CreateSecretRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateSecretRequest"

  @enforce_keys []
  defstruct [:value]

  @type t :: %__MODULE__{
    value: list(integer()),
    }
end


defmodule FlyMachinesApi.FlyDuration do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyDuration"

  @enforce_keys []
  defstruct [:"time.Duration"]

  @type t :: %__MODULE__{
    "time.Duration": integer(),
    }
end


defmodule FlyMachinesApi.CreateMachineRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateMachineRequest"

  @enforce_keys []
  defstruct [:config, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration]

  @type t :: %__MODULE__{
    config: any(),
    lease_ttl: integer(),
    lsvd: boolean(),
    name: String.t(),
    region: String.t(),
    skip_launch: boolean(),
    skip_service_registration: boolean(),
    }
end


defmodule FlyMachinesApi.MachineVersion do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineVersion"

  @enforce_keys []
  defstruct [:user_config, :version]

  @type t :: %__MODULE__{
    user_config: %FlyMachinesApi.FlyMachineConfig{},
    version: String.t(),
    }
end


defmodule FlyMachinesApi.ErrorResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ErrorResponse"

  @enforce_keys []
  defstruct [:details, :error, :status]

  @type t :: %__MODULE__{
    details: any(),
    error: String.t(),
    status: %FlyMachinesApi.MainstatusCode{},
    }
end


defmodule FlyMachinesApi.FlyTLSOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyTLSOptions"

  @enforce_keys []
  defstruct [:alpn, :default_self_signed, :versions]

  @type t :: %__MODULE__{
    alpn: list(String.t()),
    default_self_signed: boolean(),
    versions: list(String.t()),
    }
end


defmodule FlyMachinesApi.FlyMachineInit do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineInit"

  @enforce_keys []
  defstruct [:cmd, :entrypoint, :exec, :kernel_args, :swap_size_mb, :tty]

  @type t :: %__MODULE__{
    cmd: list(String.t()),
    entrypoint: list(String.t()),
    exec: list(String.t()),
    kernel_args: list(String.t()),
    swap_size_mb: integer(),
    tty: boolean(),
    }
end


defmodule FlyMachinesApi.FlyHTTPOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyHTTPOptions"

  @enforce_keys []
  defstruct [:compress, :h2_backend, :headers_read_timeout, :idle_timeout, :response]

  @type t :: %__MODULE__{
    compress: boolean(),
    h2_backend: boolean(),
    headers_read_timeout: integer(),
    idle_timeout: integer(),
    response: %FlyMachinesApi.FlyHTTPResponseOptions{},
    }
end


defmodule FlyMachinesApi.ListSecret do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListSecret"

  @enforce_keys []
  defstruct [:label, :publickey, :type]

  @type t :: %__MODULE__{
    label: String.t(),
    publickey: list(integer()),
    type: String.t(),
    }
end


defmodule FlyMachinesApi.FlyMachineServiceConcurrency do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineServiceConcurrency"

  @enforce_keys []
  defstruct [:hard_limit, :soft_limit, :type]

  @type t :: %__MODULE__{
    hard_limit: integer(),
    soft_limit: integer(),
    type: String.t(),
    }
end


defmodule FlyMachinesApi.FlyMachineSecret do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineSecret"

  @enforce_keys []
  defstruct [:env_var, :name]

  @type t :: %__MODULE__{
    env_var: String.t(),
    name: String.t(),
    }
end


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


defmodule FlyMachinesApi.FlyMachineHTTPHeader do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineHTTPHeader"

  @enforce_keys []
  defstruct [:name, :values]

  @type t :: %__MODULE__{
    name: String.t(),
    values: list(String.t()),
    }
end


defmodule FlyMachinesApi.CreateOIDCTokenRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateOIDCTokenRequest"

  @enforce_keys []
  defstruct [:aud]

  @type t :: %__MODULE__{
    aud: String.t(),
    }
end


defmodule FlyMachinesApi.FlyMachineGuest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineGuest"

  @enforce_keys []
  defstruct [:cpu_kind, :cpus, :gpu_kind, :gpus, :host_dedication_id, :kernel_args, :memory_mb]

  @type t :: %__MODULE__{
    cpu_kind: String.t(),
    cpus: integer(),
    gpu_kind: String.t(),
    gpus: integer(),
    host_dedication_id: String.t(),
    kernel_args: list(String.t()),
    memory_mb: integer(),
    }
end


defmodule FlyMachinesApi.Organization do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Organization"

  @enforce_keys []
  defstruct [:name, :slug]

  @type t :: %__MODULE__{
    name: String.t(),
    slug: String.t(),
    }
end


defmodule FlyMachinesApi.UpdateMachineRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.UpdateMachineRequest"

  @enforce_keys []
  defstruct [:config, :current_version, :lease_ttl, :lsvd, :name, :region, :skip_launch, :skip_service_registration]

  @type t :: %__MODULE__{
    config: any(),
    current_version: String.t(),
    lease_ttl: integer(),
    lsvd: boolean(),
    name: String.t(),
    region: String.t(),
    skip_launch: boolean(),
    skip_service_registration: boolean(),
    }
end


defmodule FlyMachinesApi.FlyStopConfig do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyStopConfig"

  @enforce_keys []
  defstruct [:signal, :timeout]

  @type t :: %__MODULE__{
    signal: String.t(),
    timeout: %FlyMachinesApi.FlyDuration{},
    }
end


defmodule FlyMachinesApi.FlyMachineMount do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineMount"

  @enforce_keys []
  defstruct [:add_size_gb, :encrypted, :extend_threshold_percent, :name, :path, :size_gb, :size_gb_limit, :volume]

  @type t :: %__MODULE__{
    add_size_gb: integer(),
    encrypted: boolean(),
    extend_threshold_percent: integer(),
    name: String.t(),
    path: String.t(),
    size_gb: integer(),
    size_gb_limit: integer(),
    volume: String.t(),
    }
end


defmodule FlyMachinesApi.FlyMachineMetrics do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineMetrics"

  @enforce_keys []
  defstruct [:path, :port]

  @type t :: %__MODULE__{
    path: String.t(),
    port: integer(),
    }
end


defmodule FlyMachinesApi.CreateLeaseRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateLeaseRequest"

  @enforce_keys []
  defstruct [:description, :ttl]

  @type t :: %__MODULE__{
    description: String.t(),
    ttl: integer(),
    }
end


defmodule FlyMachinesApi.ExtendVolumeRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ExtendVolumeRequest"

  @enforce_keys []
  defstruct [:size_gb]

  @type t :: %__MODULE__{
    size_gb: integer(),
    }
end


defmodule FlyMachinesApi.MachineExecRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineExecRequest"

  @enforce_keys []
  defstruct [:cmd, :command, :timeout]

  @type t :: %__MODULE__{
    cmd: String.t(),
    command: list(String.t()),
    timeout: integer(),
    }
end


defmodule FlyMachinesApi.Lease do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Lease"

  @enforce_keys []
  defstruct [:description, :expires_at, :nonce, :owner, :version]

  @type t :: %__MODULE__{
    description: String.t(),
    expires_at: integer(),
    nonce: String.t(),
    owner: String.t(),
    version: String.t(),
    }
end


defmodule FlyMachinesApi.FlydnsOption do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlydnsOption"

  @enforce_keys []
  defstruct [:name, :value]

  @type t :: %__MODULE__{
    name: String.t(),
    value: String.t(),
    }
end


defmodule FlyMachinesApi.App do
  @moduledoc "Automatically generated struct for FlyMachinesApi.App"

  @enforce_keys []
  defstruct [:id, :name, :organization, :status]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    organization: %FlyMachinesApi.Organization{},
    status: String.t(),
    }
end


defmodule FlyMachinesApi.StopRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.StopRequest"

  @enforce_keys []
  defstruct [:signal, :timeout]

  @type t :: %__MODULE__{
    signal: String.t(),
    timeout: %FlyMachinesApi.FlyDuration{},
    }
end


defmodule FlyMachinesApi.UpdateVolumeRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.UpdateVolumeRequest"

  @enforce_keys []
  defstruct [:auto_backup_enabled, :snapshot_retention]

  @type t :: %__MODULE__{
    auto_backup_enabled: boolean(),
    snapshot_retention: integer(),
    }
end


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


defmodule FlyMachinesApi.FlyMachineProcess do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineProcess"

  @enforce_keys []
  defstruct [:cmd, :entrypoint, :env, :env_from, :exec, :ignore_app_secrets, :secrets, :user]

  @type t :: %__MODULE__{
    cmd: list(String.t()),
    entrypoint: list(String.t()),
    env: any(),
    env_from: list(%FlyMachinesApi.FlyEnvFrom{}),
    exec: list(String.t()),
    ignore_app_secrets: boolean(),
    secrets: list(%FlyMachinesApi.FlyMachineSecret{}),
    user: String.t(),
    }
end


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


defmodule FlyMachinesApi.FlyProxyProtoOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyProxyProtoOptions"

  @enforce_keys []
  defstruct [:version]

  @type t :: %__MODULE__{
    version: String.t(),
    }
end


defmodule FlyMachinesApi.FlyFile do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyFile"

  @enforce_keys []
  defstruct [:guest_path, :mode, :raw_value, :secret_name]

  @type t :: %__MODULE__{
    guest_path: String.t(),
    mode: integer(),
    raw_value: String.t(),
    secret_name: String.t(),
    }
end


defmodule FlyMachinesApi.ListAppsResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListAppsResponse"

  @enforce_keys []
  defstruct [:apps, :total_apps]

  @type t :: %__MODULE__{
    apps: list(%FlyMachinesApi.ListApp{}),
    total_apps: integer(),
    }
end


defmodule FlyMachinesApi.FlyMachineRestart do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyMachineRestart"

  @enforce_keys []
  defstruct [:gpu_bid_price, :max_retries, :policy]

  @type t :: %__MODULE__{
    gpu_bid_price: any(),
    max_retries: integer(),
    policy: String.t(),
    }
end


defmodule FlyMachinesApi.CreateAppRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateAppRequest"

  @enforce_keys []
  defstruct [:app_name, :enable_subdomains, :network, :org_slug]

  @type t :: %__MODULE__{
    app_name: String.t(),
    enable_subdomains: boolean(),
    network: String.t(),
    org_slug: String.t(),
    }
end


defmodule FlyMachinesApi.FlyEnvFrom do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyEnvFrom"

  @enforce_keys []
  defstruct [:env_var, :field_ref]

  @type t :: %__MODULE__{
    env_var: String.t(),
    field_ref: String.t(),
    }
end


defmodule FlyMachinesApi.SignalRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.SignalRequest"

  @enforce_keys []
  defstruct [:signal]

  @type t :: %__MODULE__{
    signal: String.t(),
    }
end


defmodule FlyMachinesApi.VolumeSnapshot do
  @moduledoc "Automatically generated struct for FlyMachinesApi.VolumeSnapshot"

  @enforce_keys []
  defstruct [:created_at, :digest, :id, :retention_days, :size, :status]

  @type t :: %__MODULE__{
    created_at: String.t(),
    digest: String.t(),
    id: String.t(),
    retention_days: integer(),
    size: integer(),
    status: String.t(),
    }
end


defmodule FlyMachinesApi.FlyStatic do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyStatic"

  @enforce_keys [:guest_path, :url_prefix]
  defstruct [:guest_path, :index_document, :tigris_bucket, :url_prefix]

  @type t :: %__MODULE__{
    guest_path: String.t(),
    index_document: String.t(),
    tigris_bucket: String.t(),
    url_prefix: String.t(),
    }
end


defmodule FlyMachinesApi.FlydnsForwardRule do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlydnsForwardRule"

  @enforce_keys []
  defstruct [:addr, :basename]

  @type t :: %__MODULE__{
    addr: String.t(),
    basename: String.t(),
    }
end


defmodule FlyMachinesApi.MachineEvent do
  @moduledoc "Automatically generated struct for FlyMachinesApi.MachineEvent"

  @enforce_keys []
  defstruct [:id, :request, :source, :status, :timestamp, :type]

  @type t :: %__MODULE__{
    id: String.t(),
    request: any(),
    source: String.t(),
    status: String.t(),
    timestamp: integer(),
    type: String.t(),
    }
end


defmodule FlyMachinesApi.FlyDNSConfig do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyDNSConfig"

  @enforce_keys []
  defstruct [:dns_forward_rules, :hostname, :hostname_fqdn, :nameservers, :options, :searches, :skip_registration]

  @type t :: %__MODULE__{
    dns_forward_rules: list(%FlyMachinesApi.FlydnsForwardRule{}),
    hostname: String.t(),
    hostname_fqdn: String.t(),
    nameservers: list(String.t()),
    options: list(%FlyMachinesApi.FlydnsOption{}),
    searches: list(String.t()),
    skip_registration: boolean(),
    }
end


defmodule FlyMachinesApi.ListApp do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListApp"

  @enforce_keys []
  defstruct [:id, :machine_count, :name, :network]

  @type t :: %__MODULE__{
    id: String.t(),
    machine_count: integer(),
    name: String.t(),
    network: any(),
    }
end


defmodule FlyMachinesApi.ProcessStat do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ProcessStat"

  @enforce_keys []
  defstruct [:command, :cpu, :directory, :listen_sockets, :pid, :rss, :rtime, :stime]

  @type t :: %__MODULE__{
    command: String.t(),
    cpu: integer(),
    directory: String.t(),
    listen_sockets: list(%FlyMachinesApi.ListenSocket{}),
    pid: integer(),
    rss: integer(),
    rtime: integer(),
    stime: integer(),
    }
end


defmodule FlyMachinesApi.ListenSocket do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ListenSocket"

  @enforce_keys []
  defstruct [:address, :proto]

  @type t :: %__MODULE__{
    address: String.t(),
    proto: String.t(),
    }
end


defmodule FlyMachinesApi.ExtendVolumeResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ExtendVolumeResponse"

  @enforce_keys []
  defstruct [:needs_restart, :volume]

  @type t :: %__MODULE__{
    needs_restart: boolean(),
    volume: %FlyMachinesApi.Volume{},
    }
end


defmodule FlyMachinesApi.CreateVolumeRequest do
  @moduledoc "Automatically generated struct for FlyMachinesApi.CreateVolumeRequest"

  @enforce_keys []
  defstruct [:compute, :compute_image, :encrypted, :fstype, :name, :region, :require_unique_zone, :size_gb, :snapshot_id, :snapshot_retention, :source_volume_id]

  @type t :: %__MODULE__{
    compute: %FlyMachinesApi.FlyMachineGuest{},
    compute_image: String.t(),
    encrypted: boolean(),
    fstype: String.t(),
    name: String.t(),
    region: String.t(),
    require_unique_zone: boolean(),
    size_gb: integer(),
    snapshot_id: String.t(),
    snapshot_retention: integer(),
    source_volume_id: String.t(),
    }
end


defmodule FlyMachinesApi.Volume do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Volume"

  @enforce_keys []
  defstruct [:attached_alloc_id, :attached_machine_id, :auto_backup_enabled, :block_size, :blocks, :blocks_avail, :blocks_free, :created_at, :encrypted, :fstype, :host_status, :id, :name, :region, :size_gb, :snapshot_retention, :state, :zone]

  @type t :: %__MODULE__{
    attached_alloc_id: String.t(),
    attached_machine_id: String.t(),
    auto_backup_enabled: boolean(),
    block_size: integer(),
    blocks: integer(),
    blocks_avail: integer(),
    blocks_free: integer(),
    created_at: String.t(),
    encrypted: boolean(),
    fstype: String.t(),
    host_status: String.t(),
    id: String.t(),
    name: String.t(),
    region: String.t(),
    size_gb: integer(),
    snapshot_retention: integer(),
    state: String.t(),
    zone: String.t(),
    }
end


defmodule FlyMachinesApi.Flydv1ExecResponse do
  @moduledoc "Automatically generated struct for FlyMachinesApi.Flydv1ExecResponse"

  @enforce_keys []
  defstruct [:exit_code, :exit_signal, :stderr, :stdout]

  @type t :: %__MODULE__{
    exit_code: integer(),
    exit_signal: integer(),
    stderr: String.t(),
    stdout: String.t(),
    }
end


defmodule FlyMachinesApi.ImageRef do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ImageRef"

  @enforce_keys []
  defstruct [:digest, :labels, :registry, :repository, :tag]

  @type t :: %__MODULE__{
    digest: String.t(),
    labels: any(),
    registry: String.t(),
    repository: String.t(),
    tag: String.t(),
    }
end


defmodule FlyMachinesApi.FlyHTTPResponseOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyHTTPResponseOptions"

  @enforce_keys []
  defstruct [:headers, :pristine]

  @type t :: %__MODULE__{
    headers: any(),
    pristine: boolean(),
    }
end
