defmodule Todo.Database.Worker do
  use GenServer

  # --- Client API ---

  def start_link([db_folder]) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  # --- Server callbacks ---

  @impl GenServer
  def init(db_folder) do
    IO.puts("Starting database worker.")
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    data =
      key
      |> file_name(state)
      |> File.read()
      |> case do
        {:ok, content} -> :erlang.binary_to_term(content)
        {:error, _} -> nil
      end

    {:reply, data, state}
  end

  # --- Private ---
  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end
end
