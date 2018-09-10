defmodule SequenceManagerTask do
  @moduledoc """
  Problem Statement logic starts here.
  This module creates a number of tasks, that individually
  work on a sequence of numbers to find the correct set of 
  numbers, the sum of squares of which is a perfect square.

  Number of tasks created = approximately N/k +- 1
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Creates an agent to keep the state of an integer count. This
  count is incremented everytime a worker is spawned and is
  decremented everytime a worker finishes by returning the result.
  A key 'done' is initialized to false.
  This SequenceManagerTask is started by using the child_spec 
  attributes.
  """
  def start(opts) do
    Task.start(fn ->
      {:ok, counterAgent} = Agent.start_link(fn -> %{:taskCount => 0, :done => :false}  end)
      args = opts[:args]
      findSequencesInRange(String.to_integer(Enum.at(args, 0)), String.to_integer(Enum.at(args, 1)), counterAgent)
      waitForResults(counterAgent, opts[:application])
    end)
  end

  @doc """
  This method waits until a message is received from any of the
  workers. Whenever a result message is received, it updates the
  agent by decrementing the count.
  If count = 0 and done = true, all workers are finished sending
  back the result and thus the SequenceManagerTask can exit. It
  exits by sending back :done message to the AppSupervisor. 
  """
  def waitForResults(counterAgent, caller) do
    receive do
      {:taskResult, result} ->
        Enum.each(result, fn out ->
          IO.puts(out)
        end)
        Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount)-1))
        remainingTasks = Agent.get(counterAgent, &Map.get(&1, :taskCount))
        alldone = Agent.get(counterAgent, &Map.get(&1, :done))
        if remainingTasks == 0 and alldone == :true do
          send caller, {:done}
        else
          waitForResults(counterAgent, caller)
        end

    end
  end

  @doc """
  Starts a new worker and updates the agent by incrementing the
  count. 
  """
  defp startTask(start, k, n, counterAgent) do
    {:ok, task} = SequenceFinderTask.start()
    Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount)+1))
    send(task, {:startTask, start, k, n, self()})
  end

  @doc """
  This is executeed when the limiting condition index>n is 
  reached. As a result, the key 'done' is made true. This 
  means that the SequenceManagerTask has spawned all the 
  required number of worker tasks.
  """
  defp startSequenceFinder(index, n, _k, counterAgent) when index > n do
    Agent.update(counterAgent, &Map.put(&1, :done, :true))
  end

  defp startSequenceFinder(index, n, k, counterAgent) do
    startTask(index, k, n, counterAgent)
    startSequenceFinder(index + k + 1, n, k, counterAgent)
  end

  defp findSequencesInRange(n, k, counterAgent) do
    startSequenceFinder(1, n, k, counterAgent)
  end
end
