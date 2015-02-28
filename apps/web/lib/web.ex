defmodule Web do
  use Application

  def start(_type, _args) do
    Plug.Adapters.Cowboy.http(Web.Server, [])
  end
end
