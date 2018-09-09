defmodule AppSupervisor do
  @moduledoc """
  Creates a supervisor for the complete application,
  which ensures that the application ends only after 
  all computation is completed. 
  In the case that the child, SequenceManagerTask, 
  crashes, this module restarts the SequenceManagerTask
  and all computation will start over again. 
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts[:args], opts)
  end

  @doc """
  Defines a single child, SequenceManagerTask, with
  supervision strategy as one_for_one, so that if the 
  child dies, it will be the only one restarted. 
  """
  def init(args) do
    children = [
      {SequenceManagerTask, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
