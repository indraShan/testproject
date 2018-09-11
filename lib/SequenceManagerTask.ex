defmodule SequenceResultTask do
  def start(counterAgent, caller) do
    Task.start(fn ->
      waitForResults(counterAgent, caller, 0)
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
  defp waitForResults(counterAgent, caller, count) do
    receive do
      {:taskDone} ->
        Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount) - 1))
        remainingTasks = Agent.get(counterAgent, &Map.get(&1, :taskCount))
        alldone = Agent.get(counterAgent, &Map.get(&1, :done))

        if remainingTasks == 0 and alldone == true do
          send(caller, {:done})
        else
          waitForResults(counterAgent, caller, count)
        end
      {:taskResult, result} ->
        IO.puts(result)
        count = count + 1
        # IO.puts("Current count = #{count}")
        waitForResults(counterAgent, caller, count)
    end
  end
end

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
      {:ok, counterAgent} = Agent.start_link(fn -> %{:taskCount => 0, :done => false} end)
      args = opts[:args]
      {:ok, resultTask} = SequenceResultTask.start(counterAgent, opts[:application])

      findSequencesInRange(
        String.to_integer(Enum.at(args, 0)),
        String.to_integer(Enum.at(args, 1)),
        counterAgent,
        resultTask
      )
    end)
  end

  @doc """
  Starts a new worker and updates the agent by incrementing the
  count.
  """
  defp startTask(rangeStart, rangeEnd, k, n, resultTask, counterAgent) do
    Agent.update(counterAgent, &Map.put(&1, :taskCount, Map.get(&1, :taskCount) + 1))
    SequenceFinderTask.start(rangeStart, rangeEnd, k, n, resultTask)
  end

  defp loadFactorForInput(n, k) do
    cond do
      n <= 1000 ->
        n

      n > 1000 and n <= 10000 ->
        div(n, 10)

      true ->
        div(n, k)
    end
  end

  defp findSequencesInRange(n, k, counterAgent, resultTask) do
    loadFactor = loadFactorForInput(n, k)

    stream =
      Stream.unfold(1, fn x ->
        if x <= n do
          startTask(x, x + loadFactor, k, n, resultTask, counterAgent)
          {:ok, x + loadFactor + 1}
        else
          Agent.update(counterAgent, &Map.put(&1, :done, true))
          nil
        end
      end)

    Stream.run(stream)
  end
end
