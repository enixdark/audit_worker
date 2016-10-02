defmodule Audit.Cloud.Worker do
  use GenServer
  require Logger

  # defstart start_link(_), do: initial_state(0)

  def start_link(otps \\ []) do
    Logger.info "start worker Cloud...................."
    GenServer.start_link(__MODULE__, [], otps)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast(command, state) do
    pid = get(state)
    case command do
      {:update, module, ref} ->
        Logger.info "run Cloud...................."
        Audit.Cloud.Process.update(pid, module, ref)
    end
    {:noreply, Map.put(state, :conn, pid)}
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref})
  end


  @doc """
    get pid of worker when it started
  """
  @spec get(any) :: pid

  defp get(state) do
    pid = Map.get(state,:conn, nil)
    if pid == nil do
      {:ok, pid } = Audit.Cloud.Process.start_link(Application.get_env(:audit, :cloud_host),
                                                  Application.get_env(:audit, :cloud_port),
                                                  Application.get_env(:audit, :cloud_username),
                                                  Application.get_env(:audit, :cloud_password),
                                                  Application.get_env(:audit, :cloud_db))
    end
    pid
  end


end