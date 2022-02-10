
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start do
    receive do
      {:bind, peers, peer_num, max_num_broadcast, timeout} ->
        IO.puts("Starting Peer #{peer_num}")
        Process.send_after(self(), {:timeout}, timeout)
        receive_map = Enum.reduce(0..length(peers) - 1, %{}, fn id, acc ->
          Map.put(acc, :"#{id}", [0, 0])
        end)
        next_receive(peers, peer_num, max_num_broadcast, 0, receive_map)
    end
  end

  defp next_receive(peers, peer_num, max_num_broadcast, num_of_sent_b, receive_map) do
    receive do
      { :timeout } ->
        print_final_state(peer_num, receive_map)
      {:broadcast, from_peer_num, pid} ->
        new_receive_map = if from_peer_num != -1 do
          Map.update!(receive_map, :"#{from_peer_num}",
            fn existing_map ->
              [Enum.at(existing_map, 0), Enum.at(existing_map, 1) + 1]
            end)
          else
            receive_map
          end

        if num_of_sent_b < max_num_broadcast do
          next_broadcast(peers, peer_num, max_num_broadcast, num_of_sent_b, new_receive_map)
        else
          next_receive(peers, peer_num, max_num_broadcast, num_of_sent_b, new_receive_map)
        end
    end

  end

  defp next_broadcast(peers, peer_num, max_num_broadcast, num_of_sent_b, receive_map) do
    Enum.each(peers, fn x ->
      send x, {:broadcast, peer_num, self()}
    end)

    new_receive_map = Enum.reduce(0..length(peers) - 1, receive_map, fn id, acc ->
      Map.replace(acc, :"#{id}", [Enum.at(receive_map[:"#{id}"], 0) + 1, Enum.at(receive_map[:"#{id}"], 1)])
    end)

    next_receive(peers, peer_num, max_num_broadcast, num_of_sent_b + 1, new_receive_map)
  end

  defp print_final_state(peer_num, receive_map) do
    string_state = Enum.reduce(Map.keys(receive_map), "Peer #{peer_num}:", fn id, acc ->
      "#{acc} #{id}:#{state_for_peer_n(receive_map, id)}"
    end)
    IO.puts(string_state)
  end

  defp state_for_peer_n(receive_map, n) do
    "{#{Enum.at(receive_map[:"#{n}"], 0)}, #{Enum.at(receive_map[:"#{n}"], 1)}}"
  end

end # Peer
