
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Client do

  def start(num, perfect_link_pids, max_num_broadcast, receive_map) do
    IO.puts("Starting Client #{num}")
    receive do
      {:bind, _peer_pid, pl_pid} ->
        IO.puts("Binding client")
        next_receive(num, pl_pid, perfect_link_pids, max_num_broadcast, 0, receive_map)
    end
  end

  defp next_receive(num, pl_pid, perfect_link_pids, max_num_broadcast, num_of_sent_b, receive_map) do
    receive do
      {:timeout} ->
        print_final_state(num, receive_map)
      {:pl_deliver, from_pid} ->
        new_receive_map = if from_pid != nil do
          Map.update!(receive_map, from_pid,
            fn existing_map ->
              [Enum.at(existing_map, 0), Enum.at(existing_map, 1) + 1]
            end)
          else
            receive_map
          end

        if num_of_sent_b < max_num_broadcast do
          next_broadcast(num, pl_pid, perfect_link_pids, max_num_broadcast, num_of_sent_b, new_receive_map)
        else
          next_receive(num, pl_pid, perfect_link_pids, max_num_broadcast, num_of_sent_b, new_receive_map)
        end
    end

  end

  defp next_broadcast(num, pl_pid, perfect_link_pids, max_num_broadcast, num_of_sent_b, receive_map) do
    Enum.each(perfect_link_pids, fn x ->
      send pl_pid, {:pl_send, x}
    end)

    new_receive_map = Enum.reduce(perfect_link_pids, receive_map, fn id, acc ->
      Map.replace(acc, id, [Enum.at(receive_map[id], 0) + 1, Enum.at(receive_map[id], 1)])
    end)

    next_receive(num, pl_pid, perfect_link_pids, max_num_broadcast, num_of_sent_b + 1, new_receive_map)
  end

  defp print_final_state(num, receive_map) do
    string_state = Enum.reduce(Map.keys(receive_map), "Peer #{num}:", fn pid, acc ->
      "#{acc} #{inspect(pid)}:#{state_for_peer_n(receive_map, pid)}"
    end)
    IO.puts(string_state)
  end

  defp state_for_peer_n(receive_map, pid) do
    "{#{Enum.at(receive_map[pid], 0)}, #{Enum.at(receive_map[pid], 1)}}"
  end

end # PL
