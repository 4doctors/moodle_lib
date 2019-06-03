defmodule MoodleLib.Client.CoursesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.Client.Courses

  test "it can retrieve the list of all categories" do
    # right now 2 courses are preseeded on the Moodle DB: Test Course 1 (id: 3, "testcourse1") belonging to category 1.1 and Test Course 2 (id: 4, testcourse2) category 2
    use_cassette "get_courses", match_requests_on: [:query] do
      {:ok, courses} = Courses.get_courses()

      assert Enum.any?(courses, &(&1.shortname == "testcourse1"))
      assert Enum.any?(courses, &(&1.shortname == "testcourse2"))
      assert Enum.count(courses) > 0
    end
  end

  test "it gets the course details" do
    use_cassette "get_course_contents", match_requests_on: [:query] do
      {:ok, course_contents} = Courses.get_course_contents(3)

      assert Enum.any?(course_contents, &(&1.name == "General"))
      assert Enum.any?(course_contents, &(&1.name == "Topic 1"))
    end
  end
end
