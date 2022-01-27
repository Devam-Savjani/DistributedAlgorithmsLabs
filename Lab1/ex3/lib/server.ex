
# distributed algorithms, n.dulay, 10 jan 22
# simple client-server, v1

defmodule Server do

def start do
  IO.puts "-> Server at #{Helper.node_string()}"
  next()
end # start

defp next() do
  receive do
    { :circle, pid, radius } ->
      send pid, { :result, 3.14159 * radius * radius }
    { :square, pid, side } ->
      send pid, { :result, side * side }
  end # receive
  next()
end # next

end # Server
