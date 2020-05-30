defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  require Logger

  @behaviour Commanded.Scheduler.Job

  def execute(schedule_uuid, command) do
    IO.puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    IO.puts "Commanded.Scheduler.DispatcherCommanded.Scheduler.DispatcherCommanded.Scheduler.Dispatcher"
    IO.puts "Attempting to trigger schedule #{inspect schedule_uuid} #{inspect command}"
    Logger.debug(fn -> "Attempting to trigger schedule #{inspect schedule_uuid}" end)

    test = Commanded.Scheduler.App.dispatch(command)
    IO.inspect test
    IO.puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    test
  end
end
