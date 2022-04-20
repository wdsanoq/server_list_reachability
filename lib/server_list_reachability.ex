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

  def resolve_hostname(hostname) do
    case :inet.getaddr(hostname, :inet) do
      {:ok, ip} ->
        Enum.join(Tuple.to_list(ip), ".")

      {:error, error} ->
        error
    end
  end

  def get_socks(server) do
    name = Map.get(server, "socks_name")
    fullname = "#{name}"
    # eip = resolve_hostname(to_charlist(fullname))
    # "socks5 #{eip} 1080"
    "socks5h://#{fullname}:1080"
  end

  def list_servers() do
    get_json('servers.json')
  end

  def result() do
    get_json('servers.json')
    |> filter_servers
    |> Enum.map(&get_socks(&1))
  end

  def write_file() do
    content =
      get_json('servers.json')
      |> filter_servers
      |> Enum.map(&get_socks(&1))
      |> Enum.join("\n")

    File.write!("socks5.txt", content)
  end
end

# IO.puts(inspect(ServerListReachability.result()))
# ServerListReachability.write_file()
# IO.inspect(ServerListReachability.list_servers())
