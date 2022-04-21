defmodule ServerListReachability do
  require Poison
  require HTTPoison
  require ServerRequest

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

  def filter_server_by_country_code(list, code) do
    Enum.filter(
      list,
      fn
        %{"country_code" => x} when x == code -> true
        _ -> false
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

  def list_servers() do
    get_json('servers.json')
  end

  def get_socks_host(server) do
    name = Map.get(server, "socks_name")
    "#{name}"
  end

  def get_socks(server) do
    fullname = get_socks_host(server)
    # eip = resolve_hostname(to_charlist(fullname))
    # "socks5 #{eip} 1080"
    "socks5://#{fullname}:1080"
  end

  def get_poison_proxy(server) do
    host =
      get_socks_host(server)
      |> to_charlist()

    [host, 1080]
  end

  def result() do
    get_json('servers.json')
    |> filter_servers
    |> filter_server_by_country_code("us")
    |> Enum.map(&get_poison_proxy(&1))
  end

  def write_file() do
    content =
      get_json('servers.json')
      |> filter_servers
      |> Enum.map(&get_socks(&1))
      |> Enum.join("\n")

    File.write!("socks5.txt", content)
  end

  def try_server(hostname, proxy) do
    result = ServerRequest.check(hostname, proxy)
    IO.puts("Accessed with #{List.first(proxy)}: {#{result}}")
  end

  def check_server(hostname, country_code) do
    proxy_servers =
      get_json('servers.json')
      |> filter_servers
      |> filter_server_by_country_code(country_code)
      |> Enum.map(&get_poison_proxy(&1))

    proxy_servers
    |> Enum.each(&try_server(hostname, &1))
  end
end

# ServerListReachability.check_server("https://ifconfig.me", "us")
# ServerListReachability.write_file()
# IO.inspect(ServerListReachability.result())
