defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    IO.puts("Starting to-do cache.")
    Todo.Database.start_link()
    {:ok, %{}}
  end

  def start_link(_) do
    # GenServer.start(Todo.Cache, nil)
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, pid} ->
        {:reply, pid, todo_servers}

      :error ->
        {:ok, pid} = Todo.Server.start_link(todo_list_name)
        {:reply, pid, Map.put(todo_servers, todo_list_name, pid)}
    end
  end
end
