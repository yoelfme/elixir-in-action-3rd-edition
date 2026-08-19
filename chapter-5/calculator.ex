defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  def value(server_pid) do
    send(server_pid, {:value, self()})
    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, value) do
    send(server_pid, {:add, value})
  end

  def sub(server_pid, value) do
    send(server_pid, {:sub, value})
  end

  def mul(server_pid, value) do
    send(server_pid, {:mul, value})
  end

  def div(server_pid, value) do
    send(server_pid, {:div, value})
  end

  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(message, current_value)
      end

    loop(new_value)
  end

  defp process_message({:add, value}, current_value) do
    current_value + value
  end

  defp process_message({:sub, value}, current_value) do
    current_value - value
  end

  defp process_message({:mul, value}, current_value) do
    current_value * value
  end

  defp process_message({:div, value}, current_value) do
    current_value / value
  end

  defp process_message({:value, caller}, current_value) do
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(_, current_value) do
    current_value
  end
end
