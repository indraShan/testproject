defmodule SequenceManagerTask do
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
      # parse args, get n and k
      findSequencesInRange(String.to_integer(Enum.at(opts,0)), String.to_integer(Enum.at(opts,1)), [])
    end)
  end

  # 1, 2, 3

  # 1, 24, 40
  # 26, 24, 40
  # defp startTask(start, k, n) do
  #   {:ok, task} = SequenceFinderTask.start([])
  #   send(task, {:find_sequence, start, k, n, self()})
  # end

  defp startTask(start, k, n) do
    task = SequenceFinderTask.taskForRange(start, k, n)

    Enum.each(Task.await(task), fn out ->
      IO.puts(out)
    end)

    task
  end

  # defp startSequenceFinder(index, n, _k) when index > n do
  #   nil
  # end

  # 1, 3, 2
  # 4, 3, 2

  # 1, 40, 24
  # 26, 40, 24
  # defp startSequenceFinder(index, n, k) do
  #   startTask(index, k, n)
  #   startSequenceFinder(index + k + 1, n, k)
  # end

  defp startSequenceFinder(index, n, _k) when index > n do
    []
  end

  defp startSequenceFinder(index, n, k) do
    [startTask(index, k, n)] ++ startSequenceFinder(index + k + 1, n, k)
  end

  def processTasks([task | tasks]) do
    processTasks(task) ++ processTasks(tasks)
  end

  def processTasks([]), do: []

  def processTasks(task) do
    result = [Task.await(task)]

    Enum.each(result, fn number ->
      IO.puts(number)
    end)

    Task.shutdown(task)
    result
  end

  defp findSequencesInRange(n, k, _result) do
    # # For the given range, start  required number of SequenceFinderTask's
    # startSequenceFinder(1, n, k)
    #
    # # start wating for responses from the tasks we have spawned
    #
    # readInbox(n, k, div(n, k), result)

    # # For the given range, start  required number of SequenceFinderTask's
    startSequenceFinder(1, n, k)

    # Enum.each(tasks, fn(task) ->
    #    Task.await(task) |> func(result) ->
    # end
    # )

    # output = processTasks(tasks)
    #
    # IO.inspect("#{output}")
  end

  # defp readInbox(n, k, unfinished, result) do
  #     IO.puts("readInbox called. unfinished = #{unfinished}")
  #
  #     receive do
  #       {:result, start} ->
  #         # If the result is positive, add the result
  #         # Irrespective of the result, kill the task as it has done its job.
  #         # Once all the tasks have done their job - print/write result, kill self?
  #
  #         result = start ++ result
  #         IO.puts("received called. unfinished}")
  #         IO.puts("unfinished = #{unfinished}")
  #
  #         if unfinished - 1 == 0 do
  #           IO.inspect("#{result}")
  #         else
  #           readInbox(n, k, unfinished - 1, result)
  #         end
  #     end
  #   end
end
