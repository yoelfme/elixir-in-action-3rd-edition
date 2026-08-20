defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  def start do
    GenServer.start(Todo.Cache, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, pid} ->
        {:reply, pid, todo_servers}

      :error ->
        {:ok, pid} = Todo.Server.start(todo_list_name)
        {:reply, pid, Map.put(todo_servers, todo_list_name, pid)}
    end
  end
end
