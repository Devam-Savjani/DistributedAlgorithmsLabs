# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start do
    IO.puts("Starting Peer")
    receive do
      {:bind, node_num, peers, value} -> next(node_num, peers, nil, nil, 0, value)
    end
  end

  def next(node_num, peers, parent, parent_pid, child_count, reduction_value) do
    receive do
      {:hello, pid, from_node} ->
        if parent == nil do
          Enum.each(peers, fn x ->
              send x, {:hello, self(), node_num}
          end)
          if pid do
            send pid, {:child}
          end
          next(node_num, peers, from_node, pid, child_count, reduction_value)
        else
          next(node_num, peers, parent, parent_pid, child_count, reduction_value)
        end
        {:child} ->
          next(node_num, peers, parent, parent_pid, child_count + 1, reduction_value)
      after
        1_000 ->
          IO.puts("Peer #{node_num} Parent #{parent} Children = #{child_count}")
          nextProp(node_num, parent, parent_pid, child_count, reduction_value)
    end

  end

  defp nextProp(node_num, parent, parent_pid, child_count, reduction_value) do
    if (child_count == 0) do
      send parent_pid, {:value, reduction_value}
      IO.puts("-------------- Peer #{node_num} Parent #{parent} Value = #{reduction_value}")
    else
      receive do
        {:value, value} ->
          if (child_count == 1) do
            send parent_pid, {:value, reduction_value + value}
            IO.puts("-------------- Peer #{node_num} Parent #{parent} Value = #{reduction_value + value}")
          else
            nextProp(node_num, parent, parent_pid, child_count - 1, reduction_value + value)
          end
      end
    end

  end

end # Peer
