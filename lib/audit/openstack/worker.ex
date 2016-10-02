defmodule Audit.Openstack.Worker do
  use GenServer
  require Logger

  def start_link([]) do
    Logger.info "start worker OpenStack...................."
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(command, _from, state) do
    pid = get(state)
    result = case command do
      {:fetch, module, ref} -> 
        Audit.Openstack.Process.fetch(pid, module, ref)
    end
    {:reply, result, Map.put(state, :conn, pid)}
  end

  def handle_cast(command, state) do
    pid = get(state)
    case command do
      {:update, module, ref} ->
        Audit.Openstack.Process.update(pid, module, ref)
    end
    {:noreply, Map.put(state, :conn, pid)}
  end

  def fetch(pid, module, ref) do
    GenServer.call(pid, {:fetch, module, ref})
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref})
  end

  defp get(state) do
    pid = Map.get(state,:conn, nil)
    if pid == nil do
      {:ok, pid } = Audit.Openstack.Process.start_link
    end
    pid
  end
end
