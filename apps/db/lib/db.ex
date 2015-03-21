defmodule Db do
  use Application
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      :poolboy.child_spec(:db,
                    [{:name, {:local, :db}}, {:worker_module, Db.Worker},
                    {:size, 4},
                    {:max_overflow, 4}], [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def start(_type, _args) do
    Db.start_link
  end

  def credentials(env \\ Mix.env) do
    Application.get_all_env(:db)
    |> set_env(env)
    |> Keyword.take([:hostname, :database, :username, :password])
    |> Enum.filter(fn({_, v}) -> v != "" end)
  end

  def add(url) do
    :poolboy.transaction(:db, fn(worker) ->
      GenServer.call(worker, {:add, url})
    end)
  end

  def expand(code) do
    :poolboy.transaction(:db, fn(worker) ->
      case GenServer.call(worker, {:expand, Base62.decode!(code)}) do
        nil -> :not_found
        url -> url
      end
    end)
  end

  def get(code) do
    :poolboy.transaction(:db, fn(worker) ->
      GenServer.call(worker, {:get, Base62.decode!(code)})
    end)
  end

  def statistics(code) do
    :poolboy.transaction(:db, fn(worker) ->
      GenServer.call(worker, {:statistics, Base62.decode!(code)})
    end)
  end

  defp set_env(creds, env) do
    prefix = Keyword.get(creds, :database_prefix)
    Keyword.put(creds, :database, "#{prefix}_#{env}")
  end
end
