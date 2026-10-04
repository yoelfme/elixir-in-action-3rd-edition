defmodule Todo.Server do
  # use GenServer, restart: :temporary
  use Agent, restart: :temporary

  def start_link(todo_list_name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting to-do server for #{todo_list_name}.")

        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(todo_list_name)
    )
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def add_entry(todo_server, new_entry) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def entries(pid, date) do
    Agent.get(
      todo_server,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  def update_entry(pid, entry_id, updater_fun) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      {name, Todo.List.update_entry(todo_list, entry_id, updater_fun)}
    end)
  end

  def delete_entry(todo_server, entry_id) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      {name, Todo.List.delete_entry(todo_list, entry_id)}
    end)
  end
end
