defmodule TailCalling do
  def list_len(list) do
    do_list_len(0, list)
  end

  def do_list_len(counter, []) do
    counter
  end

  def do_list_len(counter, [_head | tail]) do
    do_list_len(counter + 1, tail)
  end

end

TailCalling.list_len([1,2,3]) # 3
