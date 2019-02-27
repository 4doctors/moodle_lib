defmodule MoodleLib.Client.CohortsTest do
  use ExUnit.Case

  alias MoodleLib.Client.{Cohorts, Users}

  @default_params %{
    name: "Test",
    idnumber: "test"
  }

  test "it can retrieve a cohort given its id" do
    {:ok, org} = Cohorts.create_cohort(@default_params)

    {:ok, cohort} = Cohorts.get_cohort(org.id)

    on_exit(fn -> Cohorts.delete_cohort(cohort.id) end)

    assert cohort.id == org.id
    assert cohort.name == "Test"
  end

  test "it can create a cohort" do
    {:ok, cohort} = Cohorts.create_cohort(@default_params)

    on_exit(fn -> Cohorts.delete_cohort(cohort.id) end)

    assert cohort.name == "Test"
    assert cohort.idnumber == "test"
  end

  test "it can delete a cohort given its id" do
    {:ok, cohort} = Cohorts.create_cohort(@default_params)

    assert {:ok, _message} = Cohorts.delete_cohort(cohort.id)
  end

  test "it can add a user to the cohort" do
    {:ok, user} =
      Users.create_user(%{
        username: "john",
        email: "j.doe@example.com",
        firstname: "John",
        lastname: "Doe"
      })

    {:ok, cohort} = Cohorts.create_cohort(@default_params)

    {:ok, users} = Cohorts.get_cohort_members(cohort.id)
    refute Enum.member?(users, user.id)

    {:ok, users} = Cohorts.add_user_to_cohort(cohort, user)
    assert Enum.member?(users, user.id)

      {:ok, users} = Cohorts.remove_user_from_cohort(cohort, user)
    refute Enum.member?(users, user.id)

    on_exit(fn ->
      Users.delete_user(user.id)
      Cohorts.delete_cohort(cohort.id)
    end)
  end
end
