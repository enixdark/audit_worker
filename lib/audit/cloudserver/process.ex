defmodule Audit.CloudServer.Process do
  use GenServer
  require Timex
  require Logger

  use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy, size: 1


  # use ExActor.GenServer

  def start_link(host \\ "localhost" ,port \\ 27017, username \\ '', password \\ '', db \\ '') do
    GenServer.start_link(__MODULE__,{host, port, username, password, db}, [])
  end

  @doc """
    init conection to mongodb
  """
  @spec init({String.t, number, String.t, String.t, String.t}) :: {atom, Mongo.Connection}

  def init({host,port, username, password, db}) do
    case {username,password} do
       {"",""} ->  __MODULE__.start_link(hostname: host, port: port,database: db)
       {user,pwd} -> __MODULE__.start_link(hostname: host, port: port, 
                                     username: user, password: pwd, database: db, pool_size: 1)
    end
  end



  # def handle_call(command, _from, state) do
  #   collection = state |> Audit.cloud.Process.collection
  #   data = case command do
  #     :fetch -> collection |> Mongo.Collection.find
  #                          |> Enum.to_list
  #     {:find, query} -> collection |> Mongo.Collection.find(query)
  #                                  |> Enum.to_list
  #   end
  #   {:reply, data, state}
  # end

  def handle_cast(command, state) do
    case command do
      {:update, module, ref} ->
        __MODULE__ |> Mongo.find(Application.get_env(:audit, :trial_coll), %{}, batch_size: 0) 
          |> Enum.to_list
          |> Enum.map(&Task.async(
          fn ->
            ref |> module.update(%{email: &1["email"]}, %{ "$set": %{trial_started_at: &1["trial_started_at"], 
              trial_expired_at: &1["trial_expired_at"]}})
          end
        )) |> Enum.map(&Task.await(&1, Application.get_env(:audit, :timeout)))
    end
    {:noreply, state}
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref })
  end

  # def fetch(pid), do: GenServer.call(pid, :fetch, Application.get_env(:audit, :timeout))
  # def find(pid,query), do: GenServer.call(pid, {:find, query}, Application.get_env(:audit, :timeout))


end
