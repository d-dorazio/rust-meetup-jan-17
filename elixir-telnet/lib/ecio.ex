defmodule Ecio do
  use Application

  def start(_type, _args) do
    children = [
      Supervisor.Spec.worker(Ecio.Server, [Application.get_env(:ecio, :port)])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule Ecio.Server do
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
          # sleep between 500ms and 1sec
          timeout = 500 + :rand.uniform(500)
          Ecio.Logger.log "got line \"#{String.trim line}\" sleeping for #{timeout}ms"

          Process.sleep timeout

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

defmodule Ecio.Logger do
  def log(msg) do
    # Elixir does not have a DateTime library that supports timezones...
    IO.puts "#{DateTime.utc_now} #{Kernel.inspect self()}: #{msg}"
  end
end