defmodule WhereMachines.ClusterState do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    node_name = Node.self()
    connected_nodes = Node.list()

    Logger.info("ClusterState initializing on node #{node_name}. Connected nodes: #{inspect connected_nodes}")
    Logger.info("Subscribing to app:status topic")

    Phoenix.PubSub.subscribe(:where_pubsub, "app:status")

    Logger.info("Subscription to app:status complete")
    {:ok, %{}}
  end

  def handle_info({:app_started, node}, state) do
    Logger.info("✅ app_started message received from node: #{inspect node}")
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
