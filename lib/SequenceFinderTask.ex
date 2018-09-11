defmodule SequenceFinderTask do
  def start(rangeStart, rangeEnd, k, n, caller) do
    Task.start(fn ->
      findSequenceInRange(rangeStart, rangeEnd, k, n, caller)
    end)
  end

  defp calculateForRange(rangeStart, rangeEnd, _k, n, caller)
       when rangeStart > n or rangeStart > rangeEnd do
    send(caller, {:taskDone})
  end

  defp calculateForRange(rangeStart, rangeEnd, k, n, caller) do
    findSequence(rangeStart, rangeStart + k - 1, caller)
    calculateForRange(rangeStart + 1, rangeEnd, k, n, caller)
  end

  defp findSequenceInRange(rangeStart, rangeEnd, k, n, caller) do
    calculateForRange(rangeStart, rangeEnd, k, n, caller)
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
  defp findSequence(s, k, caller) do
    num = k * (k + 1) * (2 * k + 1)
    prev_seq = (s - 1) * s * (2 * s - 1)

    num = num - prev_seq

    div_num = div(num, 6)
    sq = :math.sqrt(div_num)

    if sq - round(sq) == 0 do
      send(caller, {:taskResult, s})
    else
      nil
    end
  end
end
