defmodule MoodleLib.Client.CohortsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.Client.{Cohorts, Users}

  @default_params %{
    name: "Test",
    idnumber: "test"
  }

  test "it can create/get/delete cohorts" do
    use_cassette "managing_cohorts", match_requests_on: [:query] do
      {:ok, org} = Cohorts.create_cohort(@default_params)
      assert org.name == "Test"
      assert org.idnumber == "test"

      {:ok, cohort} = Cohorts.get_cohort(org.id)
      assert cohort.id == org.id
      assert cohort.name == "Test"

      assert {:ok, _message} = Cohorts.delete_cohort(cohort.id)
    end
  end

  # test "it can manage cohort users" do
  #   use_cassette "managing_cohort_users", match_requests_on: [:query] do
  #     {:ok, user} =
  #       Users.create_user(%{
  #         username: "john",
  #         email: "j.doe@example.com",
  #         firstname: "John",
  #         lastname: "Doe"
  #       })

  #     {:ok, cohort} = Cohorts.create_cohort(@default_params)

  #     {:ok, users} = Cohorts.add_user_to_cohort(cohort, user)
  #     assert Enum.member?(users, user.id)

  #     # we need to use on_exit because it runs on a separate process
  #     # so we can record the same call with the right results
  #     # remove_user_from_cohort calls get_cohort_members under the hood
  #     on_exit(fn ->
  #       use_cassette "managing_cohort_users-cleanup", match_requests_on: [:query] do
  #         {:ok, users} = Cohorts.remove_user_from_cohort(cohort, user)
  #         refute Enum.member?(users, user.id)

  #         {:ok, _} = Users.delete_user(user.id)
  #         {:ok, _} = Cohorts.delete_cohort(cohort.id)
  #       end
  #     end)
  #   end
  # end
end
