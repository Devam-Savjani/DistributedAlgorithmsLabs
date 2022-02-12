
# distributed algorithms, n.dulay, 10 jan 22
# lab3 - broadcast algorithms

# v1 - elixir broadcast

defmodule Broadcast do

def start do
  config = Helper.node_init()
  start(config, config.start_function)
end # start/0

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "--> Broadcast at #{Helper.node_string()}"

  num_of_peers = 5
  peers = Enum.map(0..num_of_peers - 1, fn(n) ->
    Node.spawn(:'peer#{n}_#{config.node_suffix}', Peer, :start, [])
  end)

  peers
    |> Enum.with_index
    |> Enum.each(fn({pid, i}) ->
      send pid, { :bind, self(), i, 1000, 3000}
  end)

  perfect_link_pids = process_perfect_links(num_of_peers, [])
  perfect_link_pids
    |> Enum.with_index
    |> Enum.each(fn({pid, _i}) ->
      send pid, { :bind, perfect_link_pids}
  end)

  peers
    |> Enum.with_index
    |> Enum.each(fn({pid, _i}) ->
      send pid, { :perfect_link_pids, perfect_link_pids}
  end)

  Enum.each(perfect_link_pids, fn x ->
    send x, { :broadcast, nil}
  end)

end # start/2

defp process_perfect_links(num_of_peers, perfect_link_pids) do
  if num_of_peers == length(perfect_link_pids) do
    perfect_link_pids
  else
    receive do
      {:peer_link, pid} ->
        process_perfect_links(num_of_peers, [pid | perfect_link_pids])
    end
  end


end

end # Broadcast
