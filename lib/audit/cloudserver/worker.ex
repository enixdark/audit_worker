defmodule Audit.CloudServer.Worker do
  use GenServer
  require Logger

  def start_link(otps \\ []) do
    Logger.info "start worker CloudServer...................."
    GenServer.start_link(__MODULE__, [], otps)
  end

  def init(_) do
    {:ok, %{}}
  end

  # def handle_call(_command, from, state) do
  #   {:ok, conn } = Audit.CloudServer.Process.start_link(Application.get_env(:audit, :trial_host),
  #                                                       Application.get_env(:audit, :trial_port))
  #   {:reply, conn, state}
  # end

  def handle_cast(command, state) do
    pid = get(state)
    case command do
      {:update, module, ref} ->
        Audit.CloudServer.Process.update(pid, module, ref)
    end
    {:noreply, Map.put(state, :conn, pid)}
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref})
  end

  defp get(state) do
    pid = Map.get(state,:conn, nil)
    if pid == nil do
      {:ok, pid } = Audit.CloudServer.Process.start_link(Application.get_env(:audit, :trial_host),
                                                  Application.get_env(:audit, :trial_port),
                                                  Application.get_env(:audit, :trial_username),
                                                  Application.get_env(:audit, :trial_password),
                                                  Application.get_env(:audit, :trial_db))
    end
    pid
  end
end