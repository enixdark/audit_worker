defmodule Audit.Mixfile do
  use Mix.Project

  def project do
    [app: :audit,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Cli],
     preferred_cli_env: [espec: :test],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [
                    :logger,
                    :mongodb,
                    :poison,
                     :tzdata,
                    :json,
                    :httpoison,
                    :quantum,
                    :poolboy,
                    :amnesia,
                    :exrm,
                    :exactor,
                    ],
      # erl_opts: [parse_transform: "lager_transform"]
     mod: {Audit, []}
     ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     # {:logger_file_backend, "~> 0.0.8"},
     # {:tzdata, "~> 0.5.8"},
     {:tzdata, "== 0.1.8", override: true},
     # {:mock, "~> 0.1.1", only: :test},
     # {:bson, "~> 0.4.4"},
     {:meck, "~> 0.8.4", [only: :test, hex: :meck, optional: false, override: true]},
     {:mongodb, ">= 0.0.0"},
     {:gen_fsm, "~> 0.1.0"},
     {:exrm, "~> 0.18.1"},
     {:json, "~> 0.3.3"},
     {:poison, "~> 2.0"},
     {:httpoison, "~> 0.8.0"},
     {:quantum, ">= 1.7.1"},
     {:poolboy, "~> 1.5"},
     # {:exq, "~> 0.7.1"},
     {:amnesia, "~> 0.2.4"},
     {:exactor, "~> 2.2", warn_missing: false},
     {:espec, "~> 0.8.21", only: :test},
   ]
  end
end

