use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo],
  schedule_interval: 60_000,
  max_retries: 3,
  job_timeout: :infinity,
  event_stores: [Commanded.Scheduler.EventStore]

config :commanded_scheduler, Commanded.Scheduler.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  database: "commanded_scheduler_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

import_config "#{Mix.env()}.exs"
