
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule Peer do

  def start do
    receive do
      {:bind, broadcast_pid, peer_num, max_num_broadcast, timeout} ->
        IO.puts("Starting Peer #{peer_num}")
        Process.send_after(self(), {:timeout}, timeout)

        pl = spawn(PL, :start, [peer_num])
        send broadcast_pid, {:peer_link, pl}

        receive do
          {:perfect_link_pids, perfect_link_pids} ->
            receive_map = Enum.reduce(perfect_link_pids, %{}, fn id, acc ->
              Map.put(acc, id, [0, 0])
            end)
            client = spawn(Client, :start, [peer_num, perfect_link_pids, max_num_broadcast, receive_map])

            send client, {:bind, self(), pl}
            send pl, {:bind, client, pl}
            Process.send_after(client, {:timeout}, timeout)
        end


    end
  end

end # Peer
