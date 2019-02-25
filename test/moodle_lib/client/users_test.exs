defmodule MoodleLib.Client.UsersTest do
  use ExUnit.Case

  alias MoodleLib.{Client.Users, User}

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

    %User{} = new_user = Users.build_user(params)

    assert new_user.email == params.email
  end

  test "it puts all non standard fileds onto customfields" do
    params = %{
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com",
      something: "else"
    }

    new_user = Users.build_user(params)

    assert new_user.customfields.something == params.something
  end

  test "it can create a new user" do
    {:ok, new_user} = Users.create_user(@default_params)

    on_exit(fn -> Users.delete_user(new_user.id) end)

    assert new_user.id |> to_string() =~ ~r/^\d+$/
    assert new_user.username == "j.doe"
  end

  test "it can delete a user" do
    {:ok, new_user} = Users.create_user(@default_params)

    assert {:ok, _message} = Users.delete_user(new_user.id)
  end

  test "it can retriecve user details" do
    {:ok, new_user} = Users.create_user(@default_params)
    {:ok, user_details} = Users.get_user(new_user.id)

    on_exit(fn -> Users.delete_user(new_user.id) end)

    assert user_details.email == @default_params.email
    assert user_details.firstname == @default_params.firstname
    assert user_details.lastname == @default_params.lastname
  end

  test "it can retrieve multiple users given their ids" do
    {:ok, user1} = Users.create_user(@default_params)

    {:ok, user2} =
      Users.create_user(%{
        username: "jane",
        email: "jane@example.com",
        firstname: "Jane",
        lastname: "Doe"
      })

    on_exit(fn ->
      Users.delete_user(user1.id)
      Users.delete_user(user2.id)
    end)

    {:ok, users} = Users.get_users([user1.id, user2.id])
    assert Enum.count(users) == 2
    assert users |> Enum.map(&Map.take(&1, [:id])) == [%{id: user1.id}, %{id: user2.id}]
  end
end
