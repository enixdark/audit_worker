use Mix.Config

#setup for httpoison to request uri through web services
config :audit, :max_connection, System.get_env("MAX_CONECTION") || 50 
config :audit, :delay, System.get_env("DELAY") || 2_000
config :audit, :timeout, System.get_env("TIMEOUT") || 1_00_000


#setup auth for billing
config :audit, :username, System.get_env("AUDIT_USERNAME") || ""
config :audit, :password,  System.get_env("AUDIT_PASSWORD") || ""
config :audit, :tenantname, System.get_env("AUDIT_TENANTNAME") || ""

#==================================================
#config database from mongodb
config :audit, :cloud_host, System.get_env("CLOUD_HOST") || "localhost"
config :audit, :cloud_port, System.get_env("CLOUD_PORT") ||27017
config :audit, :cloud_username, System.get_env("CLOUD_USERNAME") || ""
config :audit, :cloud_password, System.get_env("CLOUD_PASSWORD") || ""
config :audit, :cloud_db, System.get_env("CLOUD_DATABASE") || "cloud"
config :audit, :vcloud_coll, System.get_env("CLOUD_COLLECTION") ||"user"


config :audit, :trial_host, System.get_env("TRIAL_HOST") || "localhost"
config :audit, :trial_port, System.get_env("TRIAL_PORT") || 27017
config :audit, :trial_username, System.get_env("TRIAL_USERNAME") || ""
config :audit, :trial_password, System.get_env("TRIAL_PASSWORD") || ""
config :audit, :trial_db, System.get_env("TRIAL_DATABASE") || "server"
config :audit, :trial_coll, System.get_env("TRIAL_COLLECTION") || "trial"


config :audit, :audit_host, System.get_env("AUDIT_HOST") || "localhost"
config :audit, :audit_port, System.get_env("AUDIT_PORT") || 27018
config :audit, :audit_username, System.get_env("AUDIT_USER") || ""
config :audit, :audit_password, System.get_env("AUDIT_PASSWORD") || ""
config :audit, :audit_db, System.get_env("AUDIT_DATABASE") || "audit"
config :audit, :audit_coll, System.get_env("AUDIT_COLLECTION") || "user"

#==================================================
#config for uri from openstack and billing
config :audit, :openstack_uri, System.get_env("OPENSTACK_URI") || "https://localhost"
config :audit, :token_uri, System.get_env("TOKEN_URI") || "https://localhost"
config :audit, :billing_uri, System.get_env("BILLING_URI") || "http://localhost"

