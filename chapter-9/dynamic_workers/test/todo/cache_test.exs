defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache_pid} = Todo.Cache.start()

    bob_pid = Todo.Cache.server_process(cache_pid, "bob")

    assert bob_pid != Todo.Cache.server_process(cache_pid, "alice")
    assert bob_pid == Todo.Cache.server_process(cache_pid, "bob")
  end

  test "to-do operations" do
    {:ok, cache_pid} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache_pid, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2026-01-01], title: "Buy a cat"})

    entries = Todo.Server.entries(alice, ~D[2026-01-01])
    assert [%{date: ~D[2026-01-01], title: "Buy a cat"}] = entries
  end
end
