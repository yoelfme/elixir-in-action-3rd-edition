defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2026-01-01], title: "Buy a cat"})

    entries = Todo.Server.entries(alice, ~D[2026-01-01])
    assert [%{date: ~D[2026-01-01], title: "Buy a cat"}] = entries
  end
end
