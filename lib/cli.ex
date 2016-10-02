require IEx;
defmodule Cli do
  require Logger
  defp parse_args(args) do
    parse = OptionParser.parse(args,
      switches: [all: :boolean],
      aliases: [a: :boolean]
    )
    case parse do
      {[boolean: a], _, _} -> process(a)
      {_, _, _} -> process(:help)
    end
  end


  defp func_worker(id, module, pid, all, check) do
    case all do
      nil -> module.update(id, Audit.Storage.Worker, pid)
      _   -> module.update(id, Audit.Storage.Worker, pid, check)
    end
  end

  defp process(:help) do
    IO.puts """
      To fetch all data from billing 
      usage:
        ./audit -a true
      To fetch with new data that have updated from billing
      usage:
        ./audit -a false
    """
    System.halt(0)
  end

  defp process(all) do
    case all do
      :ok ->  :ok
      _   ->  Logger.info "Start services..................."
              Enum.map([
                         {:cloud, Audit.Cloud.Worker, nil},
                         {:openstack, Audit.Openstack.Worker, nil},
                         {:cloudserver, Audit.CloudServer.Worker, nil},
                         {:billing, Audit.Billing.Worker, all},
                        ], &Task.async(fn ->
                          {atom, module, a} = &1
                          check = case a do
                            "true" -> true
                            _ -> false
                          end
                          {:ok,pid} = Audit.Storage.Worker.start_link
                          :poolboy.transaction(
                            Audit.pool(atom),
                            fn(id) -> func_worker(id, module, pid, a, check) end,
                            Application.get_env(:audit, :timeout)
                          )
                  end
              )) |> Enum.map(&Task.await(&1, Application.get_env(:audit, :timeout)))
              Logger.info "Stop services..................."
    end
    # :timer.sleep(10000)
    System.halt(0)
  end

  def main(args) do
    process(parse_args(args))
  end

end

