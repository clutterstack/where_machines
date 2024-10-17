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
