use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo],
  schedule_interval: 60_000,
  max_retries: 3,
  job_timeout: :infinity

config :commanded_scheduler, Commanded.Scheduler.App,
  event_store: [
    adapter: Commanded.EventStore.Adapters.InMemory
  ],
  pub_sub: :local,
  registry: :local

import_config "#{Mix.env()}.exs"
