
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

# flood message through 1-hop (fully connected) network

defmodule Flooding do

def start do
  config = Helper.node_init()
  start(config, config.start_function)
end # start/0

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "-> Flooding at #{Helper.node_string()}"
  peers = Enum.map(0..9, fn(n) ->
    Node.spawn(:'peer#{n}_#{config.node_suffix}', Peer, :start, [])
  end)

  bind(peers, 0, [1, 6])
  bind(peers, 1, [0, 2, 3])
  bind(peers, 2, [1, 3, 4])
  bind(peers, 3, [1, 2, 5])
  bind(peers, 4, [2])
  bind(peers, 5, [3])
  bind(peers, 6, [0, 7])
  bind(peers, 7, [6, 8, 9])
  bind(peers, 8, [7, 9])
  bind(peers, 9, [7, 8])

  send Enum.at(peers, 0), {:hello}

end # start/2

defp bind(peers, node_num, neighbors) do
  send Enum.at(peers, node_num), { :bind, node_num, Enum.map(neighbors, fn(n) ->
    Enum.at(peers, n)
  end) }
end


end # Flooding
