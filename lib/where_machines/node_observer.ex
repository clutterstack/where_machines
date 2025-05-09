defmodule WhereMachines.NodeObserver do
  use GenServer
  require Logger

  @check_interval 5 * 60 * 1000  # 5 minutes

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # This enables more detailed monitoring
    :net_kernel.monitor_nodes(true, [:nodedown_reason])

    node_name = Node.self()
    connected_nodes = Node.list()

    Logger.info("Node observer started on #{node_name}. Connected nodes: #{inspect connected_nodes}")

    # Schedule regular health checks
    Process.send_after(self(), :check_cluster_health, @check_interval)

    {:ok, %{last_nodes: connected_nodes}}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("🟢 Node connected: #{node}")
    {:noreply, %{state | last_nodes: Node.list()}}
  end

  def handle_info({:nodedown, node, reason}, state) do
    Logger.warning("🔴 Node disconnected: #{node}, reason: #{inspect(reason)}")
    {:noreply, %{state | last_nodes: Node.list()}}
  end

  # Fallback for old-style nodedown messages (without reason)
  def handle_info({:nodedown, node}, state) do
    Logger.warning("🔴 Node disconnected: #{node}, no reason provided")
    {:noreply, %{state | last_nodes: Node.list()}}
  end

  def handle_info(:check_cluster_health, state) do
    current_nodes = Node.list()
    app_name = System.get_env("FLY_APP_NAME") || "where"

    Logger.info("Cluster health check - Current node: #{Node.self()}")
    Logger.info("Connected nodes (#{length(current_nodes)}): #{inspect current_nodes}")

    # Check for DNS resolution - this can help diagnose cluster issues
    dns_check = resolve_internal_dns(app_name)
    Logger.info("DNS resolution for #{app_name}.internal: #{inspect dns_check}")

    # Schedule next check
    Process.send_after(self(), :check_cluster_health, @check_interval)

    {:noreply, %{state | last_nodes: current_nodes}}
  end

  # Helper for DNS diagnostics
  defp resolve_internal_dns(app_name) do
    dns_name = "#{app_name}.internal"

    case :inet_res.getbyname(String.to_charlist(dns_name), :a) do
      {:ok, {:hostent, _hostname, _aliases, :inet, _size, addresses}} ->
        {:ok, Enum.map(addresses, &:inet.ntoa/1)}
      error ->
        {:error, error}
    end
  end

  # Public API for diagnostics
  def cluster_info do
    %{
      this_node: Node.self(),
      connected_nodes: Node.list(),
      cookie: Node.get_cookie(),
      visible_nodes: Node.list(:visible),
      hidden_nodes: Node.list(:hidden)
    }
  end
end
