defmodule MoodleLib.Client.UsersTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.{Client.Users, User}

  setup_all do
    {:ok, _} = HTTPoison.start()
    :ok
  end

  @default_params %{
    username: "j.doe",
    firstname: "Sir John",
    lastname: "Doe",
    email: "j.doe+something@example.com",
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

  test "institution and city are not customfields" do
    params = %{
      firstname: "John",
      lastname: "Doe",
      email: "j.doe@example.com",
      institution: "Some institution",
      city: "Some city",
      something: "else"
    }

    new_user = Users.build_user(params)

    assert Map.fetch(new_user.customfields, :institution) == :error
    assert Map.fetch(new_user.customfields, :city) == :error
    assert {:ok, _} = Map.fetch(new_user, :institution)
    assert {:ok, _} = Map.fetch(new_user, :city)
  end

  # test "it can retrieve a user by email or username" do
  #   use_cassette "retrieve_by_attrs", match_requests_on: [:query] do
  #     user_params = @default_params
  #     {:ok, new_user} = Users.create_user(user_params)
  #     {:ok, user_by_username} = Users.get_user({:username, user_params[:username]})
  #     {:ok, user_by_email} = Users.get_user({:email, user_params[:email]})

  #     on_exit(fn ->
  #       use_cassette "delete_attrs_user", match_requests_on: [:query] do
  #         Users.delete_user(user_by_email.id)
  #       end
  #     end)

  #     assert new_user.id == user_by_username.id
  #     assert new_user.id == user_by_email.id
  #   end
  # end

  # test "it can create/retrieve/delete a single user" do
  #   use_cassette "single_user", match_requests_on: [:query] do
  #     {:ok, new_user} = Users.create_user(@default_params)
  #     {:ok, user_details} = Users.get_user(new_user.id)

  #     on_exit(fn ->
  #       use_cassette "delete_single_user", match_requests_on: [:query] do
  #         Users.delete_user(new_user.id)
  #       end
  #     end)

  #     assert user_details.email == @default_params.email
  #     assert user_details.firstname == @default_params.firstname
  #     assert user_details.lastname == @default_params.lastname
  #   end
  # end

  test "it can enroll a user as student to a course" do
    # Test Course 1 (id: 3, "testcourse1")
    # admin user is user_id: 2
    use_cassette "enroll user successfully" do
      assert :ok = Users.enroll_user_to_course(2, 3)
    end
  end

  test "it returns {:error, resason if there are any problems}" do
    # Test Course 1 (id: 3, "testcourse1")
    # admin user is user_id: 2
    use_cassette "enroll user failure" do
      assert {:error, _} = Users.enroll_user_to_course(0, 3)
      assert {:error, _} = Users.enroll_user_to_course(2, 0)
    end
  end

  test "it can suspend an enrollment of a user to a course" do
    # Test Course 1 (id: 3, "testcourse1")
    # admin user is user_id: 2
    use_cassette "suspend enroll successfully" do
      assert :ok = Users.suspend_user_enrollment_to_course(2, 3)
    end
  end

  test "it returns {:error, resason} if there are any problems suspending the enrollement" do
    # Test Course 1 (id: 3, "testcourse1")
    # admin user is user_id: 2
    use_cassette "suspend enrollment failure" do
      assert {:error, _} = Users.suspend_user_enrollment_to_course(0, 3)
      assert {:error, _} = Users.suspend_user_enrollment_to_course(2, 0)
    end
  end

  # test "it can retrieve multiple users given their ids" do
  #   use_cassette "multiple_users", match_requests_on: [:query] do
  #     {:ok, user1} = Users.create_user(@default_params)

  #     {:ok, user2} =
  #       Users.create_user(%{
  #         username: "jane",
  #         email: "jane@example.com",
  #         firstname: "Jane",
  #         lastname: "Doe"
  #       })

  #     on_exit(fn ->
  #       use_cassette "delete_multiple_users", match_requests_on: [:query] do
  #         Users.delete_user(user1.id)
  #         Users.delete_user(user2.id)
  #       end
  #     end)

  #     {:ok, users} = Users.get_users([user1.id, user2.id])
  #     assert Enum.count(users) == 2
  #     assert users |> Enum.map(&Map.take(&1, [:id])) == [%{id: user1.id}, %{id: user2.id}]
  #   end
  # end
end
