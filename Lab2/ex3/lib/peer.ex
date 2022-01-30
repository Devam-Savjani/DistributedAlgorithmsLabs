
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  # add your code here, start(), next() and any other functions

  def start do
    IO.puts("Starting Peer")
    receive do
      {:bind, node_num, peers} -> next(node_num, peers, 0, nil)
    end
  end

  def next(node_num, peers, count, parent) do
    receive do
      {:hello, num} ->
        if count == 0 do
          Enum.each(peers, fn x ->
              send x, {:hello, node_num}
            end)
        end
        next(node_num, peers, count + 1, num)
      after
        1_000 ->
          IO.puts("Peer #{node_num} Parent #{parent} Messages seen = #{count}")
    end

  end

end # Peer
