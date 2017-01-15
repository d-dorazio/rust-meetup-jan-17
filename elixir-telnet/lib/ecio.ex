defmodule Ecio.Logger do
  def log(msg) do
    IO.puts "#{Kernel.inspect self()}: #{msg}"
  end
end

defmodule Ecio.Server do
  def start_supervisioned(port) do
    children = [
      Supervisor.Spec.worker(__MODULE__, [port])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_link(port, _opts \\ []) do
    {:ok, spawn_link(__MODULE__, :serve, [port])}
  end

  def serve(port) do
    Ecio.Logger.log "listening on port: #{port}"
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    try do
      accept(socket)
    after
      :gen_tcp.close(socket)
    end
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Ecio.Logger.log "client accepted"

    spawn(__MODULE__, :handle_client, [client])
    accept(socket)
  end

  def handle_client(client) do
    try do
      case read_line client do
        {:ok, line} ->
          Ecio.Logger.log "got line \"#{String.trim line}\""

          String.upcase(line) |> write_line(client)
          handle_client client
        {:error, :closed} ->
          Ecio.Logger.log "connection closed"
        _ -> ()
      end
    after
      :gen_tcp.close client
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(line, socket) do
    :ok = :gen_tcp.send(socket, line)
  end
end
