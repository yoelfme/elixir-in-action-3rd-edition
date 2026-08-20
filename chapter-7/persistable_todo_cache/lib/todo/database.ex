defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @worker_count 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    File.mkdir_p!(@db_folder)
    workers = for worker_id <- 0..(@worker_count - 1), into: %{} do
      {:ok, worker_pid} = Todo.Database.Worker.start_link(@db_folder)
      {worker_id, worker_pid}
    end

    {:ok, workers}
  end

  def handle_cast({:store, key, data}, state) do
    worker_id = choose_worker(key)
    IO.puts("Storing data for the key #{key} in worker #{worker_id}")
    Todo.Database.Worker.store(state[worker_id], key, data)
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    worker_id = choose_worker(key)
    IO.puts("Getting data for the key #{key} from worker #{worker_id}")
    data = Todo.Database.Worker.get(state[worker_id], key)
    {:reply, data, state}
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @worker_count)
  end
end
