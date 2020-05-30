defmodule Commanded.Scheduler.Jobs do
  @moduledoc false

  use GenServer

  import Ex2ms

  alias Commanded.Scheduler.{Jobs, JobSupervisor, OneOffJob, RecurringJob}

  defstruct [:schedule_table, :jobs_table]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Schedule a named one-off job using the given module, function, args to run at
  the specified date/time.
  """
  @spec schedule_once(any, atom, [any], NaiveDateTime.t() | DateTime.t()) :: :ok

  def schedule_once(name, module, args, run_at)
      when is_atom(module) do
    GenServer.call(__MODULE__, {:schedule_once, name, module, args, run_at})
  end

  @doc """
  Schedule a named recurring job using the given module, function, args to run
  repeatedly on the given schedule.
  """
  @spec schedule_recurring(any, atom, [any], String.t()) :: :ok
  def schedule_recurring(name, module, args, schedule)
      when is_atom(module) and is_bitstring(schedule) do
    GenServer.call(__MODULE__, {:schedule_recurring, name, module, args, schedule})
  end

  @doc """
  Cancel a named scheduled job.
  """
  @spec cancel(any) :: :ok | {:error, reason :: any}
  def cancel(name) do
    GenServer.call(__MODULE__, {:cancel, name})
  end

  @doc """
  Get all scheduled jobs.
  """
  def scheduled_jobs do
    GenServer.call(__MODULE__, :scheduled_jobs)
  end

  @doc """
  Get pending jobs due at the given date/time (in UTC).
  """
  def pending_jobs(now) do
    GenServer.call(__MODULE__, {:pending_jobs, now})
  end

  @doc """
  Get all currently running jobs.
  """
  def running_jobs do
    GenServer.call(__MODULE__, :running_jobs)
  end

  def run_jobs(now) do
    GenServer.call(__MODULE__, {:run_jobs, now})
  end

  def init(_) do
    state = %Jobs{
      schedule_table: :ets.new(:schedule_table, [:set, :private]),
      jobs_table: :ets.new(:jobs_table, [:set, :private])
    }

    schedule_job_run()

    {:ok, state}
  end

  def handle_call({:schedule_once, name, module, args, run_at}, _from, state) do
    IO.puts("********************************************* handle_callhandle_call")
    IO.inspect(name)
    IO.inspect(module)
    IO.inspect(args)

    reply =
      schedule_job(
        name,
        %OneOffJob{name: name, module: module, args: args, run_at: run_at},
        epoch_seconds(run_at),
        state
      )

    IO.inspect(reply)
    IO.puts("********************************************* handle_callhandle_call")
    {:reply, reply, state}
  end

  def handle_call({:schedule_recurring, name, module, args, schedule}, _from, state) do
    reply =
      schedule_job(
        name,
        %RecurringJob{name: name, module: module, args: args, schedule: schedule},
        nil,
        state
      )

    {:reply, reply, state}
  end

  def handle_call({:cancel, name}, _from, state) do
    reply = remove_job(name, state)

    {:reply, reply, state}
  end

  def handle_call(:scheduled_jobs, _from, %Jobs{schedule_table: schedule_table} = state) do
    reply =
      schedule_table
      |> :ets.tab2list()
      |> Enum.map(fn {_name, _due_at, _status, job} -> job end)

    {:reply, reply, state}
  end

  def handle_call({:pending_jobs, now}, _from, state) do
    {:reply, pending_jobs(now, state), state}
  end

  def handle_call(:running_jobs, _from, state) do
    {:reply, running_jobs(state), state}
  end

  def handle_call({:run_jobs, now}, _from, state) do
    execute_pending_jobs(now, state)

    {:reply, :ok, state}
  end

  def handle_info(:run_jobs, state) do
    utc_now() |> execute_pending_jobs(state)

    schedule_job_run()

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _object, _reason}, state) do
    {:noreply, remove_completed_job(ref, state)}
  end

  defp schedule_job(name, job, run_at, %Jobs{schedule_table: schedule_table} = state) do
    case job_exists?(name, state) do
      false ->
        :ets.insert(schedule_table, {name, run_at, :pending, job})
        :ok

      true ->
        {:error, :already_scheduled}
    end
  end

  defp remove_job(name, %Jobs{schedule_table: schedule_table} = state) do
    case job_exists?(name, state) do
      true ->
        :ets.delete(schedule_table, name)
        :ok

      false ->
        {:error, :not_scheduled}
    end
  end

  defp job_exists?(name, %Jobs{schedule_table: schedule_table}) do
    case :ets.lookup(schedule_table, name) do
      [_job] -> true
      [] -> false
    end
  end

  defp pending_jobs(now, %Jobs{schedule_table: schedule_table}) do
    due_at_epoch = epoch_seconds(now)

    predicate =
      fun do
        {_name, due_at, status, job} when due_at <= ^due_at_epoch and status == :pending -> job
      end

    :ets.select(schedule_table, predicate)
  end

  defp running_jobs(%Jobs{schedule_table: schedule_table}) do
    predicate =
      fun do
        {_name, _due_at, status, job} when status == :running -> job
      end

    :ets.select(schedule_table, predicate)
  end

  defp execute_pending_jobs(now, state) do
    for job <- pending_jobs(now, state) do
      execute_job(job, state)
    end
  end

  defp execute_job(%OneOffJob{name: name, module: module, args: args}, %Jobs{
         jobs_table: jobs_table,
         schedule_table: schedule_table
       }) do
    with {:ok, pid} <- JobSupervisor.start_job(name, module, args) do
      ref = Process.monitor(pid)

      :ets.update_element(schedule_table, name, {3, :running})
      :ets.insert(jobs_table, {ref, name})
    end
  end

  defp execute_job(%RecurringJob{name: name, module: module, args: args}, %Jobs{}) do
    {:ok, _pid} = JobSupervisor.start_job(name, module, args)
  end

  defp remove_completed_job(
         ref,
         %Jobs{jobs_table: jobs_table, schedule_table: schedule_table} = state
       ) do
    case :ets.lookup(jobs_table, ref) do
      [{ref, name}] ->
        :ets.delete(jobs_table, ref)
        :ets.delete(schedule_table, name)
        state

      _ ->
        state
    end
  end

  defp schedule_job_run, do: Process.send_after(self(), :run_jobs, schedule_interval())

  defp schedule_interval,
    do: Application.get_env(:commanded_scheduler, :schedule_interval, 60_000)

  defp epoch_seconds(%DateTime{} = due_at),
    do: DateTime.diff(due_at, DateTime.from_unix!(0), :second)

  defp epoch_seconds(%NaiveDateTime{} = due_at),
    do: NaiveDateTime.diff(due_at, ~N[1970-01-01 00:00:00], :second)

  defp utc_now, do: NaiveDateTime.utc_now()
end
