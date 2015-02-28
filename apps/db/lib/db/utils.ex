defmodule Db.Utils do
  def create_schema(env) do
    {_, pid} = Postgrex.Connection.start_link(Db.credentials(env))
    Postgrex.Connection.query(pid, "CREATE SEQUENCE stats_codes_seq START WITH 3844 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1", [])
    Postgrex.Connection.query(pid, """
    CREATE UNLOGGED TABLE IF NOT EXISTS stats (
      code integer NOT NULL DEFAULT nextval('stats_codes_seq') PRIMARY KEY,
      url varchar NOT NULL,
      open_count integer NOT NULL DEFAULT 0
    )
    """, [])
    Postgrex.Connection.query(pid, "CREATE UNIQUE INDEX index_stats_on_code ON stats USING btree (code)", [])
  end

  def clean_db(env) do
    {_, pid} = Postgrex.Connection.start_link(Db.credentials(env))
    Postgrex.Connection.query(pid, "DELETE FROM stats", [])
    Postgrex.Connection.query(pid, "ALTER SEQUENCE stats_codes_seq RESTART WITH 3844", [])
  end
end
