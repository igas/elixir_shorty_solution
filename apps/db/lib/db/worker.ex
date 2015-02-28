defmodule Db.Worker do
  use GenServer
  @behaviour :poolboy_worker

  import Postgrex.Connection

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_) do
    Postgrex.Connection.start_link(Db.credentials)
  end

  def handle_call({:add, url}, _from, pid) do
    query!(pid, "INSERT INTO stats (url) VALUES ($1)", [url])
    [{code}] = query!(pid, "SELECT code FROM stats WHERE url = $1 ORDER BY code DESC LIMIT 1", [url]).rows
    {:reply, Base62.encode(code), pid}
  end

  def handle_call({:statistics, code}, _from, pid) do
    [{count}] = query!(pid, "SELECT open_count FROM stats WHERE code = $1", [code]).rows
    {:reply, count, pid}
  end

  def handle_call({:expand, code}, _from, pid) do
    case query!(pid, "SELECT url FROM stats WHERE code = $1", [code]).rows do
      [{url}] -> {:reply, url, pid}
      _ -> {:reply, nil, pid}
    end
  end

  def handle_call({:get, code}, _from, pid) do
    query!(pid, "UPDATE stats SET open_count = open_count + 1 WHERE code = $1", [code])
    case query!(pid, "SELECT url FROM stats WHERE code = $1", [code]).rows do
      [{url}] -> {:reply, url, pid}
      _ -> {:reply, nil, pid}
    end
  end
end
