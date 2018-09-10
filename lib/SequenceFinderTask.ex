defmodule SequenceFinderTask do
  def start() do
    Task.start_link(fn -> loop() end)
  end

  defp loop() do
    receive do
      {:startTask, rangeStart, k, n, caller} ->
        result = findSequenceInRange(rangeStart, rangeStart + k, k, n)

        # if length(result) != 0 do
        #   send(caller, {:taskResult, result})
        # end
        send(caller, {:taskResult, result})
        {:ok, self()}
    end
  end

  defp calculateForRange(rangeStart, rangeEnd, _k, n)
       when rangeStart > n or rangeStart > rangeEnd do
    []
  end

  defp calculateForRange(rangeStart, rangeEnd, k, n) do
    findSequence(rangeStart, rangeStart + k - 1) ++
      calculateForRange(rangeStart + 1, rangeEnd, k, n)
  end

  defp findSequenceInRange(rangeStart, rangeEnd, k, n) do
    result = calculateForRange(rangeStart, rangeEnd, k, n)
    result
  end

  defp findSequence(s, k) do
    num = k * (k + 1) * (2 * k + 1)
    prev_seq = (s - 1) * s * (2 * s - 1)

    num = num - prev_seq

    div_num = div(num, 6)
    sq = :math.sqrt(div_num)

    if Float.floor(sq) === Float.ceil(sq) do
      [s]
    else
      []
    end
  end
end
