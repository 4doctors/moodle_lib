defmodule MoodleLib.Client.Courses do
  import MoodleLib.Client.Common, only: [process_request: 2]

  def get_courses do
    %{}
    |> process_request(:core_course_get_courses_by_field)
    |> handle_got_courses()
  end

  defp handle_got_courses(%{courses: courses_list}) do
    case courses_list do
      [_ | _] = courses ->
        {:ok, courses}

      _ ->
        {:error, message: "There was an error retrieving the list of courses"}
    end
  end
end
