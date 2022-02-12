
# distributed algorithms, n.dulay, 10 jan 22
# basic flooding, v1

defmodule PL do

  def start(num) do
    IO.puts("PL started #{num}")
    receive do
      {:bind, client, pl_pid} ->
        next(client, pl_pid)
    end
  end

  defp next(client, pl_pid) do
    receive do
      {:pl_send, dest_pl_pid} ->
        send dest_pl_pid, {:broadcast, pl_pid}
        next(client, pl_pid)
      {:broadcast, from_pl_pid} ->
        send client, {:pl_deliver, from_pl_pid}
        next(client, pl_pid)
    end
  end

end # PL
