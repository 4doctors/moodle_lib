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

  test "it can create a new user" do
    params = %{
      username: "j.doe",
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com",
      one: "extra",
      something: "else"
    }

    {:ok, new_user} = Client.create_user(params)

    on_exit(fn -> Client.delete_user(new_user.id) end)

    assert new_user.id |> to_string() =~ ~r/^\d+$/
    assert new_user.username == "j.doe"
  end

  test "it can delete a user" do
    params = %{
      username: "j.doe",
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com",
      one: "extra",
      something: "else"
    }

    {:ok, new_user} = Client.create_user(params)

    assert {:ok, _message} = Client.delete_user(new_user.id)
  end
end
