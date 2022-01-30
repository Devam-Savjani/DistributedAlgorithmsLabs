
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  # add your code here, start(), next() and any other functions

  def start do
    IO.puts("Starting Peer")
    receive do
      {:bind, peers} -> next(peers, 0)
    end
  end

  def next(peers, count) do
    receive do
      {:hello} ->
        if count == 0 do
          Enum.each(peers, fn x ->
              send x, {:hello}
            end)
        end
        next(peers, count + 1)
      after
        1_000 ->
          IO.puts("Peer #{inspect(self())} Messages seen = #{count}")
    end

  end

end # Peer
