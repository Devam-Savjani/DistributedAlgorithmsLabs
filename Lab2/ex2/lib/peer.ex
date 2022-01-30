
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  # add your code here, start(), next() and any other functions

  def start do
    IO.puts("Starting Peer")
    receive do
      {:bind, node_num, peers} -> next(node_num, peers, 0)
    end
  end

  def next(node_num, peers, count) do
    receive do
      {:hello} ->
        if count == 0 do
          Enum.each(peers, fn x ->
              send x, {:hello}
            end)
        end
        next(node_num, peers, count + 1)
      after
        1_000 ->
          IO.puts("Peer #{node_num} Messages seen = #{count}")
    end

  end

end # Peer
