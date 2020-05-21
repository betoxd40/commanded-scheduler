use Mix.Config

config :mix_test_watch,
  clear: true,
  tasks: [
    "test --no-start"
  ]

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# Configures the event store database
config :commanded_scheduler, Commanded.Scheduler.EventStore,
  serializer: Commanded.Serialization.JsonSerializer
