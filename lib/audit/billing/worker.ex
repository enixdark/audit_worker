defmodule Audit.Billing.Worker do
  use GenServer
  require Logger
  def start_link([]) do
    Logger.info "start worker Billing...................."
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, %{}}
  end


  @doc """
    process to fetch all data from billing uri and save into database
  """
  @spec handle_call(atom, pid, any) :: {atom, map, Map.t}

  def handle_call(command, _from, state) do
    pid = get(state)
    case command do
      {:update, module, ref, check} ->
        Enum.each(1..4, fn(_) ->
          Audit.Billing.Process.process(pid, module, ref, check)
        end)
        :ok
    end
    {:reply, Map.put(state, :conn, pid), state}
  end

  @doc """
    call event update in genserver handle_call
  """
  def update(pid, module, ref, check) do
    GenServer.call(pid, {:update, module, ref, check}, 2000000)
  end

  @doc """
    get pid of worker when it started
  """
  @spec get(any) :: pid

  defp get(state) do
    pid = Map.get(state,:conn, nil)
    if pid == nil do
      {:ok, pid } = Audit.Billing.Process.start_link(:init)
    end
    pid
  end

end
