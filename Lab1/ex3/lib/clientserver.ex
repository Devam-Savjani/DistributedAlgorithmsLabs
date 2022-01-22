
# distributed algorithms, n.dulay, 10 jan 22
# simple client-server, v1

defmodule ClientServer do

def start do
  config = Helper.node_init()
  start(config, config.start_function)
end # start

defp start(config, :single_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'clientserver_#{config.node_suffix}', Server, :start, [])
  client = Node.spawn(:'clientserver_#{config.node_suffix}', Client, :start, [])
  send server, { :bind, client }
  send client, { :bind, server }
end # start

defp start(_,      :cluster_wait), do: :skip
defp start(config, :cluster_start) do
  IO.puts "-> ClientServer at #{Helper.node_string()}"
  server = Node.spawn(:'server_#{config.node_suffix}', Server, :start, [])
  client1 = Node.spawn(:'client_#{config.node_suffix}', Client, :start, [])
  client2 = Node.spawn(:'client_#{config.node_suffix}', Client, :start, [])
  client3 = Node.spawn(:'client_#{config.node_suffix}', Client, :start, [])
  IO.puts("Real Server PID: #{inspect(server)}")
  IO.puts("Real Client1 PID: #{inspect(client1)}")
  IO.puts("Real Client2 PID: #{inspect(client2)}")
  IO.puts("Real Client3 PID: #{inspect(client3)}")
  send server, { :bind, client1 }
  send server, { :bind, client2 }
  send server, { :bind, client3 }
  send client1, { :bind, server }
  send client2, { :bind, server }
  send client3, { :bind, server }
end # start

end # ClientServer
