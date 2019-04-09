# Commanded scheduler

One-off command scheduler for [Commanded](https://github.com/commanded/commanded) CQRS/ES applications using [Ecto](https://github.com/elixir-ecto/ecto) for persistence.

Commands can be scheduled in one of two ways:

- Using the `Commanded.Scheduler` module as described in the [Example usage](guides/Usage.md#usage) section.
- By [dispatching a scheduled command](guides/Usage.md#dispatch-a-scheduled-command) using your app's router or from within a process manager.

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])
```

---

MIT License

[![Build Status](https://travis-ci.org/commanded/commanded-scheduler.svg?branch=master)](https://travis-ci.org/commanded/commanded-scheduler)

---

## Getting started and usage guides

- [Getting started](guides/Getting%20Started.md)
- [Usage](guides/Usage.md)
- [Testing](guides/Testing.md)
