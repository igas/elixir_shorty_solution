defmodule Web.Server do
  use Plug.Router

  plug Plug.Head
  plug Plug.Static, at: "/", from: :web
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/:code" do
    case Db.get(code) do
      :not_found -> not_found(conn)
      url ->
        put_resp_header(conn, "Location", url)
        |> send_resp(301, "")
    end
  end

  get "/statistics/:code" do
    send_resp(conn, 200, Integer.to_string(Db.statistics(code)))
  end

  get "/expand/:code" do
    send_resp(conn, 200, Db.expand(code))
  end

  post "/shorten" do
    code = Db.add(conn.params["url"])
    send_resp(conn, 201, "#{Application.get_env(:web, :url)}#{code}")
  end

  match _, do: not_found(conn)

  defp not_found(conn) do
    send_resp(conn, 404, "404")
  end
end
