defmodule MoodleLib.Client.CoursesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.Client.Courses

  test "it can retrieve the list of all categories" do
    # right now courses are preseeded on the DB: Test Course 1 ("testcourse1") belonging to category 1.1 and Test Course 2 (testcourse2) category 2
    use_cassette "get_courses", match_requests_on: [:query] do
      {:ok, courses} = Courses.get_courses()

      assert Enum.any?(courses, &(&1.shortname == "testcourse1"))
      assert Enum.any?(courses, &(&1.shortname == "testcourse2"))
      assert Enum.count(courses) > 0
    end
  end
end
