defmodule Ecio do
  def start_supervisioned(port) do
    children = [
      Supervisor.Spec.worker(Ecio, [port], [name: Foo])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_link(port, opts \\ []) do
    IO.puts "#{port}"
    spawn(Ecio, :serve, [port])
  end

  def serve(port) do
    IO.puts "serve"
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    try do
      IO.puts "ready"
      accept(socket)
    after
      :gen_tcp.close(socket)
    end
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    IO.puts "Accepted"

    spawn(Ecio, :handle_client, [client])
    accept(socket)
  end

  def handle_client(client) do
    try do
      case read_line client do
        {:ok, line} ->
          String.upcase(line) |> write_line(client)
          handle_client client
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
