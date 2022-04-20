defmodule ServerRequest do
  # require HTTPoison

  def check() do
    HTTPoison.start()
    options = [proxy: "10.0.0.1:1080"]
    HTTPoison.get!("ifconfig.me", [], options)
    # HTTPoison.get!("ifconfig.me")
  end
end

IO.inspect(ServerRequest.check())

# HTTPoison.get("ifconfig.me")
