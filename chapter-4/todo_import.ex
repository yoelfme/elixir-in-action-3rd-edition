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

defmodule TodoList.CsvImporter do
  def import(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] -> %{date: date, title: title} end)
    |> Enum.to_list()
    |> TodoList.new()
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, fn
      todo_list, {:cont, entry} -> TodoList.add_entry(todo_list, entry)
      todo_list, :done -> todo_list
      _todo_list, :halt -> :ok
    end}
  end
end


# Example usage
entries = [%{date: "2026-01-01", title: "Buy groceries"}, %{date: "2026-01-02", title: "Buy groceries"}]
todo_list = Enum.into(entries, TodoList.new())
IO.inspect(todo_list)
