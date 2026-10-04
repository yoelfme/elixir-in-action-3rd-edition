defmodule UniqueProcessRegistryTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = UniqueProcessRegistry.start_link()

    on_exit(fn ->
      if Process.alive?(pid), do: GenServer.stop(pid)
    end)

    :ok
  end

  test "registers a unique name and looks it up" do
    assert UniqueProcessRegistry.register(:some_name) == :ok
    assert UniqueProcessRegistry.register(:some_name) == :error
    assert UniqueProcessRegistry.whereis(:some_name) == self()
    assert UniqueProcessRegistry.whereis(:unregistered_name) == nil
  end

  test "removes the registration when the process exits" do
    {:ok, pid} = Agent.start_link(fn -> UniqueProcessRegistry.register(:bar) end)
    assert UniqueProcessRegistry.whereis(:bar) == pid

    Agent.stop(pid)
    Process.sleep(50)

    assert UniqueProcessRegistry.whereis(:bar) == nil
  end
end
