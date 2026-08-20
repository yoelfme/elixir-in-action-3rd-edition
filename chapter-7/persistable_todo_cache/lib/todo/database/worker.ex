defmodule Todo.Database.Worker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    data = key
    |> file_name(state)
    |> File.read()
    |> case do
      {:ok, content} -> :erlang.binary_to_term(content)
      {:error, _} -> nil
    end
    {:reply, data, state}
  end

  def file_name(key, state) do
    Path.join(state, to_string(key))
  end
end
