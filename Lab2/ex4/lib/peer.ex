
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  # add your code here, start(), next() and any other functions

  def start do
    IO.puts("Starting Peer")
    receive do
      {:bind, node_num, peers} -> next(node_num, peers, nil, 0)
    end
  end

  def next(node_num, peers, parent, child_count) do
    receive do
      {:hello, pid, from_node} ->
        if parent == nil do
          Enum.each(peers, fn x ->
              send x, {:hello, self(), node_num}
          end)
          send pid, {:child}
          next(node_num, peers, from_node, child_count)
        else
          next(node_num, peers, parent, child_count)
        end
      {:child} ->
        next(node_num, peers, parent, child_count + 1)
      after
        1_000 ->
          IO.puts("Peer #{node_num} Parent #{parent} Children = #{child_count}")
    end

  end

end # Peer
