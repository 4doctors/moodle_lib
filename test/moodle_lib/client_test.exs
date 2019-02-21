defmodule MoodleLib.ClientTest do
  use ExUnit.Case

  alias MoodleLib.{Client, User}

  @default_params %{
    username: "j.doe",
    firstname: "John",
    lastname: "Doe",
    email: "j.doe@example.com",
    one: "extra",
    something: "else"
  }

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
    {:ok, new_user} = Client.create_user(@default_params)

    on_exit(fn -> Client.delete_user(new_user.id) end)

    assert new_user.id |> to_string() =~ ~r/^\d+$/
    assert new_user.username == "j.doe"
  end

  test "it can delete a user" do
    {:ok, new_user} = Client.create_user(@default_params)

    assert {:ok, _message} = Client.delete_user(new_user.id)
  end

  test "it can retriecve user details" do
    {:ok, new_user} = Client.create_user(@default_params)
    {:ok, user_details} = Client.get_user(new_user.id)

    on_exit(fn -> Client.delete_user(new_user.id) end)

    assert user_details.email == @default_params.email
    assert user_details.firstname == @default_params.firstname
    assert user_details.lastname == @default_params.lastname
  end
end
