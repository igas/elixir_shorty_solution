defmodule Mix.Tasks.Db.Init do
  use Mix.Task

  def run(_) do
    Db.Utils.create_schema("dev")
    Db.Utils.create_schema("test")
  end
end
