defmodule Audit.Openstack.Process do
  use GenServer
  use HTTPoison.Base
  require Logger

  # @expected_fields ~w(
  #   username name
  # )

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(command, _from, state) do
    data = case command do
      {:fetch, _module, _ref } ->
        # request to uri to receive a response, then extract body in dicts of 
        Audit.Openstack.Process.get!(Audit.Openstack.Process.uri).body
    end
    {:reply, data, state}
  end

  def handle_cast(command, state) do
    case command do
      {:update, module, ref } ->
        # request to uri to get all user's infomation, then extract body in dicts of 
        users = Audit.Openstack.Process.get!(Audit.Openstack.Process.uri).body
        Enum.map(users[:users], &Task.async(
          fn ->
            # Logger.info inspect(&1)
            ref |> module.update(%{email: &1["email"]}, %{ "$set": %{status: (if &1["enabled"] == true, do: "active", else: "inactive"),
              name: &1["name"],
              openstack_id: &1["id"],
              email: &1["email"],
              username: &1["username"]
              }})
          end
        )) |> Enum.map(&Task.await(&1, Application.get_env(:audit, :timeout)))
    end
    {:noreply, state}
  end

  def fetch(pid, module, ref) do
    GenServer.call(pid, {:fetch, module, ref }, Application.get_env(:audit, :timeout))
  end

  def update(pid, module, ref) do
    GenServer.cast(pid, {:update, module, ref })
  end

  defp process_url(url), do: url

  defp process_response_body(body) do
    body
    |> Poison.decode!
    # |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def uri, do: Application.get_env(:audit, :openstack_uri)

  # defp process_request_body(body), do: body
  # defp process_response_body(body), do: body
  # defp process_request_headers(headers) when is_map(headers), do: Enum.into(headers, [])
  # defp process_request_headers(headers), do: headers
  # defp process_response_chunk(chunk), do: chunk
  # defp process_headers(headers), do: headers
  # defp process_status_code(status_code), do: status_code

end
