defmodule ServerRequest do
  def check(url, [host, port]) do
    HTTPoison.start()

    headers = [
      {"accept",
       "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
      {"accept-language", "en-US,en;q=0.9"},
      {"cache-control", "no-cache"},
      {"pragma", "no-cache"},
      {"sec-fetch-dest", "document"},
      {"sec-fetch-mode", "navigate"},
      {"sec-fetch-site", "none"},
      {"sec-fetch-user", "?1"},
      {"sec-gpc", "1"},
      {"upgrade-insecure-requests", "1"}
    ]

    options = [proxy: {:socks5, host, port}]
    HTTPoison.get!(url, headers, options).body
  end
end
