defmodule Todo.Server do
  use GenServer

  def init(todo_list) do
    {:ok, todo_list}
  end

  def start do
  GenServer.start(Todo.Server, Todo.List.new(), name: :todo_server)
  end

  def add_entry(entry) do
    GenServer.cast(:todo_server, {:add_entry, entry})
  end

  def entries(date) do
    GenServer.call(:todo_server, {:entries, date})
  end

  def update_entry(entry_id, updater_fun) do
    GenServer.cast(:todo_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    GenServer.cast(:todo_server, {:delete_entry, entry_id})
  end

  def handle_call({:entries, date}, _from, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry_id, updater_fun)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end
end
