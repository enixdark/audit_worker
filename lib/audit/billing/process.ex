defmodule Audit.Billing.Process do
  # use GenServer
  use GenFSM
  use Timex
  require Logger
  # require Audit.Cache.Model


  @auth_body Poison.encode!(%{"auth" => %{"tenantName" => Application.get_env(:audit, :tenantname), 
                         "passwordCredentials" => %{"username" => Application.get_env(:audit, :username), 
                                                    "password" => Application.get_env(:audit, :password)}}})
  @auth_header %{"Content-type" => "application/json", "Accept" => "application/json", "User-Agent" => "python-novaclient"}


  @doc """
  Starts with fsm to save state when request billing service
  """
  def start_link(state, opts \\ []) do
    GenFSM.start_link(__MODULE__, state, opts)
  end


  @doc """
    return state to start when want a start request with state
  """
  def init(state) do
    case state do
      :init -> {:ok, :get_access_token, %{}}
      :get_access_token -> {:ok, :get_accounts, %{}}
    end
  end


  @doc """
    synchronous event to call func implement request based on state
  """

  def process(pid, module, ref, check) do
    :gen_fsm.sync_send_event(pid, {:next, module, ref, check}, Application.get_env(:audit, :timeout))
  end

  @doc """
    asynchronous event to call func implement request based on state
  """

  def process_cast(pid, module, ref, check) do
    :gen_fsm.send_event(pid, {:next, module, ref, check})
  end


  @doc """
    the first request to get access token from billing uri
  """
  @spec get_access_token({atom, module, pid, boolean}, pid, any) :: {atom, atom, atom, any}

  def get_access_token({:next, _, _, _} , _from, state) do
    {next_state, response} = case HTTPoison.post(uri_for_auth, @auth_body, @auth_header, hackney: [pool: :first_pool]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: _}} ->
         data = body |> Poison.decode!
             |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
         %{"audit_ids" => audit_ids, "expires" => expires, "id" => id,
          "issued_at" => issued_at, "tenant" => tenant } = data[:access]["token"]
         {:get_accounts, Map.put_new(state, "token", data[:access]["token"])}
       {:ok, %HTTPoison.Response{status_code: 404, body: _, headers: _}} ->
         {:get_access_token, "Not found"}
       {:error, %HTTPoison.Error{reason: reason}} ->
         {:get_access_token, reason}
    end
    {:reply, next_state, next_state, response}
  end

  @doc """
    the second request to get user's ids from billing uri
  """
  @spec get_accounts({atom, module, pid, boolean}, pid, any) :: {atom, atom, atom, any}

  def get_accounts({:next, _, _, check},_from,  state) do
    request_uri = case check do
      true -> uri_for_accounts("")
      false -> {:ok, date} = Timex.format(Date.today, "%Y/%m/%d", :strftime)
               uri_for_accounts("?updated_at=#{date}")
    end
    {next_state, response} = case HTTPoison.get(request_uri, %{"Content-type" => "application/json",
      "Accept" => "application/json", "X-Auth-Token" => state["token"]["id"]}, hackney: [pool: :first_pool]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: _}} ->
        data = body |> Poison.decode!
             |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
        {:get_infos, Map.put_new(state, "ids", data)}
       {:ok, %HTTPoison.Response{status_code: 404, body: _, headers: _}} ->
        {:get_accounts, "Not found"}
       {:error, %HTTPoison.Error{reason: reason}} ->
        {:get_accounts, reason}
    end
    {:reply, next_state, next_state, response}
  end


  @doc """
    the final request to get user's infomation based on id get from second request of billing uri
  """
  @spec get_infos({atom, module, pid, boolean}, pid, any) :: {atom, atom, atom, any}

  def get_infos({:next, module, ref, _}, _from, state) do
    # Logger.info inspect(state["ids"][:accounts])
    take = state["ids"][:accounts]
    ids = if :erlang.length(take) > Application.get_env(:audit, :max_connection), 
          do: Enum.chunk(take, Application.get_env(:audit, :max_connection)), 
          else: [take]
    unless Enum.empty? ids do
      ids |> Enum.each(fn(first) ->
      first |> Enum.map(&Task.async(
        fn ->
          case HTTPoison.get(uri_for_accounts <> "/#{&1}", %{"Content-type" => "application/json",
            "Accept" => "application/json", "X-Auth-Token" => state["token"]["id"]}, hackney: [pool: :first_pool]) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: _}} ->
              # Logger.info inspect(body)
              {:ok, result} = body |> Poison.decode
              response = result["account"]
              ref |> module.update(%{email: response["name"]},
              %{email: response["name"], level: response["level"], credit_balance: response["credit_balance"], 
                bill_day: response["bill_day"], id: response["id"], referral_code: response["referral_code"]})
            {:ok, %HTTPoison.Response{status_code: 404, body: _, headers: _}} ->
              Logger.info "Not found"
            {:error, %HTTPoison.Error{reason: reason}} ->
              Logger.info reason
          end
        end
      )) |> Enum.map(&Task.await(&1, Application.get_env(:audit, :timeout)))
      :timer.sleep Application.get_env(:audit, :delay)
      end)
    end
    {:reply, :end, :ok, state}
  end

  @doc """
    the end state to ensure not any request to billing uri
  """
  @spec ok({atom, any, any, any}, pid, any) :: {atom, atom, atom, any}

  def ok({:next, _, _, _}, _from, state) do
    {:reply, :end, :ok, state}
  end

  @doc """
    uri to get access token
  """
  @spec uri_for_auth :: String.t
  def uri_for_auth, do: Application.get_env(:audit, :token_uri) 

  @doc """
    uri to get all accounts
  """
  @spec uri_for_accounts(params :: nil | String.t) :: String.t

  def uri_for_accounts(params \\ ''), do: "#{Application.get_env(:audit, :billing_uri)}#{params}" 
end
