defmodule Audit.Storage.Worker do
  use GenServer
  require Logger

  # defstart start_link(_), do: initial_state(0)

  def start_link(otps \\ []) do
    Logger.info "start worker store...................."
    GenServer.start_link(__MODULE__, [], otps)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(command, _from, state) do
    pid = get(state)
    result = case command do
      :find -> Audit.Storage.Engine.find_all(pid)
    end
    {:reply, result, Map.put(state, :conn, pid)}
  end

  def handle_cast(command, state) do
    pid = get(state)
    case command do
      {:update, query, data} ->
        # Logger.info inspect(data)
        Audit.Storage.Engine.update(pid, query, data)
    end
    {:noreply, Map.put(state, :conn, pid)}
  end

  def find(pid) do
    GenServer.call(pid, :find)
  end

  def update(pid, query, data) do
    GenServer.cast(pid, {:update, query, data})
  end

  defp get(state) do
    pid = Map.get(state,:conn, nil)
    if pid == nil do
      {:ok, pid } = Audit.Storage.Engine.start_link(Application.get_env(:audit, :audit_host),
                                                    Application.get_env(:audit, :audit_port),
                                                    Application.get_env(:audit, :audit_username),
                                                    Application.get_env(:audit, :audit_password),
                                                    Application.get_env(:audit, :audit_db))
    end
    pid
  end

end