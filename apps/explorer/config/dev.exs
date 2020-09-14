use Mix.Config

database = if System.get_env("DATABASE_URL"), do: nil, else: "explorer_dev"
hostname = if System.get_env("DATABASE_URL"), do: nil, else: "localhost"

# Configure your database
config :explorer, Explorer.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "blockscoutDatabase",
  username: "postgres",
  password: "hAtTU8zQj50ftM6BNuqG",
  hostname: "database-1.cshpsekipbeb.ap-southeast-1.rds.amazonaws.com",
  port: 5432,
  pool_size: 50,
  ssl: true,
  timeout: :timer.seconds(80)

config :explorer, Explorer.Tracer, env: "dev", disabled?: true

config :logger, :explorer,
  level: :debug,
  path: Path.absname("logs/dev/explorer.log")

config :logger, :reading_token_functions,
  level: :debug,
  path: Path.absname("logs/dev/explorer/tokens/reading_functions.log"),
  metadata_filter: [fetcher: :token_functions]

config :logger, :token_instances,
  level: :debug,
  path: Path.absname("logs/dev/explorer/tokens/token_instances.log"),
  metadata_filter: [fetcher: :token_instances]

variant =
  if is_nil(System.get_env("ETHEREUM_JSONRPC_VARIANT")) do
    "ganache"
  else
    System.get_env("ETHEREUM_JSONRPC_VARIANT")
    |> String.split(".")
    |> List.last()
    |> String.downcase()
  end

# Import variant specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "dev/#{variant}.exs"
