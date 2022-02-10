
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

  # add your code here
  peers = Enum.map(0..4, fn(n) ->
    Node.spawn(:'peer#{n}_#{config.node_suffix}', Peer, :start, [])
  end)

  peers
    |> Enum.with_index
    |> Enum.each(fn({pid, i}) ->
      send pid, { :bind, peers, i, 10_000_000, 3000}
  end)

  Enum.each(peers, fn x ->
    send x, { :broadcast, -1, self()}
  end)

end # start/2

end # Broadcast
