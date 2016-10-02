require IEx;
defmodule Audit.Storage.Engine do
  use GenServer
  # use ExActor.GenServer
  require Logger
  alias Mongo.Connection
  # use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy

  def start_link(host \\ "localhost" ,port \\ 27017, username \\ '', password \\ '', db \\ '') do
    GenServer.start_link(__MODULE__,{host, port, username, password, db}, [])
  end

  @doc """
    init conection to mongodb
  """
  @spec init({String.t, number, String.t, String.t, String.t}) :: {atom, Mongo.Connection}

  def init({host,port, username, password, db}) do
    {:ok, pid } = case {username,password} do
       {"",""} ->  Connection.start_link(hostname: host, port: port,database: db)
       {user,pwd} -> Connection.start_link(hostname: host, port: port, 
                                     username: user, password: pwd, database: db, pool_size: 1)
    end
    {:ok, pid}
  end

  def handle_call(command, _from, state) do
    data = case command do
      :find_all -> state |> Connection.find_one(Application.get_env(:audit, :audit_coll), %{}, batch_size: 0)
      {:find, query} -> state |> Connection.find_one(Application.get_env(:audit, :audit_coll), query , batch_size: 0)
    end
    {:reply, data |> Enum.to_list, state}
  end

  def handle_cast(command, state) do
    case command do
      {:create, data} -> __MODULE__ |> Connection.insert(Application.get_env(:audit, :audit_coll), data)
      {:update, query, data} ->
        try do
          # Logger.info inspect(data)
          state |> Connection.update(Application.get_env(:audit, :audit_coll),
                                       query, data, upsert: true)
        rescue
          e in RuntimeError -> 
            # Logger.error inspect(data)
            e
        end
      {:delete, query } -> :ok
      # Mongo.Connection.stop(state)  
    end
    {:noreply, state}
  end

  def find_all(pid), do: GenServer.call(pid, :find_all, Application.get_env(:audit, :timeout))
  def find(pid,query), do: GenServer.call(pid, {:find, query}, Application.get_env(:audit, :timeout))
  def create(pid, data), do: GenServer.cast(pid, {:create, data})
  # def delete(pid, query), do: GenServer.cast(pid, {:delete, query})
  def update(pid, query, data), do: GenServer.cast(pid, {:update, query, data})

  # def collection(conn), do: Audit.Storage.Engine.collection(conn,Application.get_env(:audit, :audit_db),
  #                                                                Application.get_env(:audit, :audit_coll))
  # def collection(conn, db , coll ) do
  #   conn |> Mongo.db(db)
  #        |> Mongo.Db.collection(coll)
  # end
  # def close(conn),do: conn |> Mongo.Server.close


end
