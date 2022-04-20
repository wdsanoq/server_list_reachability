defmodule ServerListReachability do
  require Poison

  def get_json(filename) do
    with {:ok, file_content} <- File.read(filename) do
      Poison.Parser.parse!(file_content, %{})
    end
  end

  def filter_servers(list) do
    Enum.filter(
      list,
      fn
        %{
          "active" => true,
          "type" => "wireguard"
        } ->
          true

        _ ->
          false
      end
    )
  end

  def get_socks(server) do
    Map.get(server, "hostname")
  end

  def result() do
    get_json('servers.json')
    |> filter_servers
    |> Enum.map(&get_socks(&1))
  end
end

IO.puts(inspect(ServerListReachability.result()))
