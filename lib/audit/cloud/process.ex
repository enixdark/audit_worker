require IEx;
defmodule Audit.Cloud.Process do
  use GenServer
  use Timex
  # require Bson
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

  @doc """
    synchronous process to query data from mongodb
  """

  # @spec handle_call(atom, pid, any) :: {atom, any, any}

  def handle_call(command, _from, state) do
    data = case command do
      :fetch -> __MODULE__ |> Mongo.find(Application.get_env(:audit, :cloud_coll), %{}, batch_size: 0) 
      {:find, query} -> Mongo.find(Application.get_env(:audit, :cloud_coll), query, batch_size: 0) 
    end
    {:reply, data |> Enum.to_list , state}
  end

  # @doc """
  #   asynchronous process to insert/update data into mongodb
  # """
  # # @spec handle_cast(atom, any) :: {atom, any}

  def handle_cast(command, state) do
   
    case command do
      {:update, module, ref} ->
        __MODULE__ |> Mongo.find(Application.get_env(:audit, :cloud_coll), %{}, batch_size: 0) 
          |> Enum.to_list
          |> Enum.map(&Task.async(
          fn ->
            ref |> module.update(%{email: &1["email"]}, %{ "$set": %{name: &1["name"], 
              address: &1["address"], phone: &1["phone"], phone_numbers: &1["phone_numbers"],
              phone_verified: &1["phone_verified"], email_verified: &1["email_verified"],
              payment_verified: &1["payment_verified"], created_at: &1["created_at"]}})
          end
        )) |> Enum.map(&Task.await(&1, Application.get_env(:audit, :timeout)))
        Mongo.Connection.stop(__MODULE__)
    end
    {:noreply, state}
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref })
  end


  def fetch(pid), do: GenServer.call(pid, :fetch, Application.get_env(:audit, :timeout))


end
