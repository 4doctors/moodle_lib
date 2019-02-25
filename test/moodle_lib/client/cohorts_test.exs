defmodule MoodleLib.Client.CohortsTest do
  use ExUnit.Case

  alias MoodleLib.Client.Cohorts

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
end
