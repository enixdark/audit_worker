# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :audit, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:audit, :key)
#
# Or configure a 3rd-party app:
#
Application.load(:tzdata)
Application.ensure_started(:tzdata)
config :logger, level: :info
# config :logger, handle_otp_reports: false
# config :logger,
#   backends: [{LoggerFileBackend, :info},
#              {LoggerFileBackend, :error}]

# config :logger, :info,
#   path: "log/info.log",
#   level: :info

# config :logger, :error,
#   path: "log/error.log",
#   level: :error

config :tzdata, :data_dir, "/etc/elixir_tzdata_data"

# config :quantum, cron: [
#     # Every minute
#     "* * * * *": {Cli, :main, [["-a","false"]]}
# ]

# config :quantum, cron: [
#     # Every minute
#     "* * * * *":      {"Heartbeat", :send},
#     # Every 15 minutes
#     "*/15 * * * *":   fn -> System.cmd("rm", ["/tmp/tmp_"]) end,
#     # Runs on 18, 20, 22, 0, 2, 4, 6:
#     "0 18-6/2 * * *": fn -> :mnesia.backup('/var/backup/mnesia') end,
#     # Runs every midnight:
#     "@daily":         &Backup.backup/0
# ]
# config :lager,
#   log_root: './log',
#   handlers: [
#     lager_console_backend: :info,
#     lager_file_backend: [file: "error.log", level: :error],
#     lager_file_backend: [file: "console.log", level: :info]
#   ]
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
