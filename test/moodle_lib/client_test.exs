defmodule MoodleLib.ClientTest do
  use ExUnit.Case

  alias MoodleLib.{Client, User}

  test "it builds up a user struct" do
    params = %{
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com"
    }

    %User{} = new_user = Client.build_user(params)

    assert new_user.email == params.email
  end

  test "it puts all non standard fileds onto customfields" do
    params = %{
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com",
      something: "else"
    }

    new_user = Client.build_user(params)

    assert new_user.customfields.something == params.something
  end

  @tag :skip
  test "it can create a new user" do
    params = %{
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com"
    }

    {:ok, new_user} = Client.create_user(params)
  end
end
