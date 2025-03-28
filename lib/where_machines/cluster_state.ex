defmodule WhereMachines.ClusterState do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # get_6pn()
    Phoenix.PubSub.subscribe(WhereMachines.PubSub, "app:status")
    {:ok, %{}}
  end

  def handle_info({:app_started, node}, state) do
    Logger.info("app_started message received")
    IO.puts("Application started on node: #{inspect node}")
    IO.puts("state? #{inspect state}")
    {:noreply, state}
  end

  def get_6pn() do
    {:ok, addrs} = :inet.getifaddrs()
    ipv6_addresses = for {interface, opts} <- addrs,
                        {:addr, addr} <- opts,
                        tuple_size(addr) == 8 do  # IPv6 addresses are 8-tuples
                          {interface, addr}
                        end
    IO.inspect(ipv6_addresses, label: "IPv6 Addresses")
  end

end
