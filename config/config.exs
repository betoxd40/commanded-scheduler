use Mix.Config

config :commanded_scheduler,
  ecto_repos: [Commanded.Scheduler.Repo],
  event_stores: [Commanded.Scheduler.EventStore],
  schedule_interval: 60_000,
  max_retries: 3,
  job_timeout: :infinity

config :commanded_scheduler, Commanded.Scheduler.App,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Commanded.Scheduler.EventStore
  ],
  pub_sub: :local,
  registry: :local

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :eventstore, EventStore.Storage, serializer: BlockFi.Thor.Domain.Support.Serializer

import_config "#{Mix.env()}.exs"
