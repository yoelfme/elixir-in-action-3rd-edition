defmodule TodoServer do
  def start do
    todo_server = spawn(fn -> loop(TodoList.new()) end)
    Process.register(todo_server, :todo_server)
    todo_server
  end

  def add_entry(entry) do
    send(:todo_server, {:add, entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5_000 -> {:error, :timeout}
    end
  end

  def update_entry(entry_id, updater_fun) do
    send(:todo_server, {:update, entry_id, updater_fun})

    receive do
      {:todo_entries, entries} -> entries
    after
      5_000 -> {:error, :timeout}
    end
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete, entry_id})
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
       message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    entries = TodoList.entries(todo_list, date)
    send(caller, {:todo_entries, entries})
    todo_list
  end

  defp process_message(todo_list, {:update, entry_id, updater_fun}) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  defp process_message(todo_list, {:delete, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, _) do
    todo_list
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
    %{todo_list | next_id: todo_list.next_id + 1, entries: new_entries}
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
        %{todo_list | entries: new_entries}

      :error ->
        todo_list
    end
  end

  def delete_entry(%TodoList{} = todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %{todo_list | entries: new_entries}
  end
end
