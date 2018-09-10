defmodule SequenceManagerTask do
  @moduledoc """
  Problem Statement logic starts here.
  This module creates a number of tasks, that individually
  work on a sequence of numbers to find the correct set of 
  numbers, the sum of squares of which is a perfect square.

  Number of tasks created = Floor(N/k)
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

  def start(opts) do
    Task.start(fn ->
      {:ok, counterAgent} = Agent.start_link(fn -> %{:taskCount => 0, :done => :false}  end)
      args = opts[:args]
      findSequencesInRange(String.to_integer(Enum.at(args, 0)), String.to_integer(Enum.at(args, 1)), counterAgent)
      waitForResults(counterAgent, opts[:application])
    end)
  end

  def waitForResults(counterAgent, caller) do
    receive do
      {:taskResult, result} ->
        Enum.each(result, fn out ->
          IO.puts(out)
        end)
        Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount)-1))
        remainingTasks = Agent.get(counterAgent, &Map.get(&1, :taskCount))
        alldone = Agent.get(counterAgent, &Map.get(&1, :done))
        # IO.puts "remainingTasks = #{remainingTasks}"
        # IO.puts "alldone = #{alldone}"
        if remainingTasks == 0 and alldone == :true do
          send caller, {:done}
        else
          waitForResults(counterAgent, caller)
        end

    end
  end

  defp startTask(start, k, n, counterAgent) do
    {:ok, task} = SequenceFinderTask.start()
    Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount)+1))
    send(task, {:startTask, start, k, n, self()})
  end

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
