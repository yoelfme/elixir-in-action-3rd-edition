defmodule TodoServer do
  use GenServer

  def init(todo_list) do
    {:ok, todo_list}
  end

  def start do
    GenServer.start(TodoServer, TodoList.new(), name: :todo_server)
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
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry_id, updater_fun)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(%TodoList{} = todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, entry.id, entry)
    %TodoList{todo_list | next_id: todo_list.next_id + 1, entries: new_entries}
  end

  def entries(%TodoList{} = todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  def update_entry(%TodoList{} = todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %TodoList{todo_list | entries: new_entries}

      :error ->
        todo_list
    end
  end

  def delete_entry(%TodoList{} = todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end
