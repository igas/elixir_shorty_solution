defmodule DbTest do
  use ExUnit.Case

  alias Faker.Internet, as: Faker

  setup do
    Db.Utils.clean_db("test")
    :ok
  end

  test :add do
    url = Faker.url
    Db.add(url)

    {_, pid} = Postgrex.Connection.start_link(Db.credentials)
    [result] = Postgrex.Connection.query!(pid, "SELECT code, url, open_count FROM stats", []).rows

    assert result == {3844, url, 0}
  end

  test :expand do
    url = Faker.url
    code = Db.add(url)

    assert Db.expand(code) == url
  end

  test :get_and_statistics do
    url = Faker.url
    code = Db.add(url)

    Db.get(code)
    Db.get(code)
    Db.get(code)

    assert Db.get(code) == url
    assert Db.statistics(code) == 4
  end
end
