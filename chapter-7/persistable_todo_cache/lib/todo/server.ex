defmodule Todo.Server do
  use GenServer

  def init(todo_list_name) do
    # The commented out code, can also work but can block the main process from loading the todo list
    # todo_list = Todo.Database.get(todo_list_name) || Todo.List.new()
    # {:ok, {todo_list_name, todo_list}}
    {:ok, {todo_list_name, nil}, {:continue, :load}}
  end

  def start(todo_list_name) do
    GenServer.start(Todo.Server, todo_list_name)
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, entry_id, updater_fun) do
    GenServer.cast(pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def handle_call({:entries, date}, _from, {todo_list_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {todo_list_name, todo_list}}
  end

  def handle_cast({:add_entry, entry}, {todo_list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)

    Todo.Database.store(todo_list_name, new_list)

    {:noreply, {todo_list_name, new_list}}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, {todo_list_name, todo_list}) do
    {:noreply, {todo_list_name, Todo.List.update_entry(todo_list, entry_id, updater_fun)}}
  end

  def handle_cast({:delete_entry, entry_id}, {todo_list_name, todo_list}) do
    {:noreply, {todo_list_name, Todo.List.delete_entry(todo_list, entry_id)}}
  end

  def handle_continue(:load, {todo_list_name, nil}) do
    todo_list = Todo.Database.get(todo_list_name) || Todo.List.new()
    {:noreply, {todo_list_name, todo_list}}
  end
end
