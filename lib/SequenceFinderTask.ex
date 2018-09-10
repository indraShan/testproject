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

  @doc """
  K here is NOT the same as k input to the application
  Desired Sequence => s s+1 ...... k

  1 2 3 ...... s ....... k

  sum of squares of first k numbers is
        k*(k+1)*(2k+1)
      -----------------
              6
  sum of squares of first s-1 numbers is
        (s-1)*(s-1+1)*(2(s-1)+1)
       --------------------------
                  6
  Hence sum of squares of numbers in desired sequence is
  the difference of the above two equations.

  Method returns a list [s] if perfect square is found
  else an empty list []
  """
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
