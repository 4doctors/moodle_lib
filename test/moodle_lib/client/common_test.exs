defmodule MoodleLib.Client.CommonTest do
  use ExUnit.Case

  alias MoodleLib.Client.Common

  test "query_params encodes symbol key hashes" do
    params = %{user: "name"}
    assert Common.query_params(params) =~ "user=name"
  end

  test "query_params encodes the right symbols" do
    params = %{"users[0][email]" => "user+test@example.com"}
    assert Common.query_params(params) =~ "users[0][email]=user%2Btest%40example.com"
  end
end
