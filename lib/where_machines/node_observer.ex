# lib/your_app/node_observer.ex (add to both apps)
defmodule WhereMachines.NodeObserver do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    :net_kernel.monitor_nodes(true)
    Logger.info("Node monitor started on #{Node.self()}")
    {:ok, nil}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("🟢 Node connected: #{node}")
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info("🔴 Node disconnected: #{node}")
    {:noreply, state}
  end
end
