defmodule Todo.System do
  # def start_link do
  #   Supervisor.start_link(
  #     [Todo.Cache],
  #     strategy: :one_for_one
  #   )
  # end
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    Supervisor.init(
      [Todo.Cache],
      strategy: :one_for_one
    )
  end
end
