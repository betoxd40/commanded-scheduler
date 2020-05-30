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
  password: "yanes6514",
  hostname: "localhost"
