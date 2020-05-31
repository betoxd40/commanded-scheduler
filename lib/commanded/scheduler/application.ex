defmodule Commanded.Scheduler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, [name: Commanded.Scheduler.JobRunner]},
      Commanded.Scheduler.App,
      Commanded.Scheduler.Repo,
      Commanded.Scheduler.JobSupervisor,
      Commanded.Scheduler.Jobs,
      Commanded.Scheduler.Scheduling,
      {Commanded.Scheduler.Projection, []}
    ]

    opts = [strategy: :one_for_one, name: Commanded.Scheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
