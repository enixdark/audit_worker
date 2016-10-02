require IEx;
defmodule Audit do
  use Application
  require Logger
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "start workers....................."
    # worker(Audit.Cache.Worker, [[name: Audit.Cache.Worker]])
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Audit.Worker, [arg1, arg2, arg3
        :hackney_pool.child_spec(:first_pool,  [timeout: Application.get_env(:audit, :timeout), 
                                                max_connections: Application.get_env(:audit, :max_connection)]),
        # worker(Audit.Cloud.Worker, [[name: Audit.Cloud.Worker]])
        # :poolboy.child_spec(pool(:cache), poolboy_config(Audit.Cache.Worker, :cache,1), [name: Audit.Cache.Worker]),
        :poolboy.child_spec(pool(:cloud), poolboy_config(Audit.Cloud.Worker, :cloud,1),[]),
        :poolboy.child_spec(pool(:cloudserver), poolboy_config(Audit.CloudServer.Worker, :cloudserver,1), []),
        :poolboy.child_spec(pool(:billing), poolboy_config(Audit.Billing.Worker, :billing,1), []),
        :poolboy.child_spec(pool(:openstack), poolboy_config(Audit.Openstack.Worker, :openstack,1), []),
        # :poolboy.child_spec(pool(:storage), poolboy_config(Audit.Storage.Worker, :storage,1), [ ]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Audit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def pool(name), do: String.to_atom("pool_#{name}")

  defp poolboy_config(module,name,size) do
    [
      {:name, {:local, pool(name)}},
      {:worker_module, module},
      {:size, size},
      {:max_overflow, 1}
    ]
  end

  

  

  end

