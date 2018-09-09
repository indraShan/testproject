defmodule SequenceFinderTask do
  def start(_opts) do
    Task.start(fn -> readInbox() end)
  end

  def taskForRange(rangeStart, k, n) do
    Task.async(fn -> findSequenceInRange(rangeStart, rangeStart + k, k, n) end)
  end

  defp readInbox() do
    receive do
      {:find_sequence, rangeStart, k, n, caller} ->
        # IO.puts("Starting task for start = #{rangeStart}")
        # 1, 24, 40
        send(caller, findSequenceInRange(rangeStart, rangeStart + k, k, n))
        readInbox()
    end
  end

  defp calculateForRange(rangeStart, rangeEnd, _k, n)
       when rangeStart > n or rangeStart > rangeEnd do
    # IO.puts("Finished ex task with start = #{rangeStart}")
    # if length(result) != 0 do
    # 	IO.inspect result
    # end
    # {:result, result}
    # Enum.each result, fn number ->
    #   IO.puts number
    # end
    []
  end

  # 1, 3, 2, 3
  # 2, 3, 2, 3
  # 3, 3, 2, 3
  # 4, 3, 2, 3
  defp calculateForRange(rangeStart, rangeEnd, k, n) do
    # 1, 2
    # 2, 3
    # 3, 4
    findSequence(rangeStart, rangeStart + k - 1) ++
      calculateForRange(rangeStart + 1, rangeEnd, k, n)
  end

  # 1, 3, 2, 3
  # 1, 25, 24, 40
  # 24, 50, 24, 40
  defp findSequenceInRange(rangeStart, rangeEnd, k, n) do
    result = calculateForRange(rangeStart, rangeEnd, k, n)
    # Enum.each result, fn number ->
    #   IO.puts number
    # end
    result
  end

  defp findSequence(s, k) do
    # IO.puts "findSequence called. s = #{s}, k = #{k}"
    num = k * (k + 1) * (2 * k + 1)
    prev_seq = (s - 1) * s * (2 * s - 1)

    num = num - prev_seq
    # IO.puts "findSequence num = #{num}"
    # IO.puts "findSequence prev_seq = #{prev_seq}"

    div_num = div(num, 6)
    # IO.puts "findSequence div_num = #{div_num}"
    sq = :math.sqrt(div_num)

    if Float.floor(sq) === Float.ceil(sq) do
      # IO.puts "seq starts with #{s}"
      # IO.puts "findSequence positive result for #{s}"
      # {:result, s}
      # IO.puts s
      [s]
    else
      # {:result, -1}
      []
    end
  end
end
