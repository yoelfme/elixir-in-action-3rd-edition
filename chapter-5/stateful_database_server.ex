defmodule DatabaseServer do
  def start do
    spawn(fn ->
      connection_id = :rand.uniform(1_000)
      loop(connection_id)
    end)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_async_result do
    receive do
      {:query_result, result} -> result
    end
  end

  defp loop(connection_id) do
    receive do
      {:run_query, from_pid, query_def} ->
        query_result = run_query(connection_id, query_def)
        send(from_pid, {:query_result, query_result})
    end

    loop(connection_id)
  end

  defp run_query(connection_id, query_def) do
    Process.sleep(2_000)
    "Connection #{connection_id}: #{query_def} result"
  end
end
