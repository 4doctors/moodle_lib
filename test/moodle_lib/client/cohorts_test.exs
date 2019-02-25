defmodule MoodleLib.Client.CohortsTest do
  use ExUnit.Case

  alias MoodleLib.Client.Cohorts

  test "it can retrieve a cohort given its id" do
    {:ok, cohort} = Cohorts.get_cohort(1)

    assert cohort.id == 1
    assert cohort.name == "Test"
  end
end
