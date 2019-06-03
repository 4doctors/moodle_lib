defmodule MoodleLib.Client.Courses do
  import MoodleLib.Client.Common, only: [process_request: 2]

  def get_courses do
    %{}
    |> process_request(:core_course_get_courses_by_field)
    |> handle_got_courses()
  end

  def get_course_contents(id) do
    %{courseid: id}
    |> process_request(:core_course_get_contents)
    |> handle_got_course_contents()
  end

  defp handle_got_courses(%{courses: courses_list}) do
    case courses_list do
      [_ | _] = courses ->
        {:ok, courses}

      _ ->
        {:error, message: "There was an error retrieving the list of courses"}
    end
  end

  defp handle_got_course_contents(response) do
    case response do
      [_ | _] = course_contents ->
        {:ok, course_contents}

      %{message: message} ->
        {:error, message: message}
    end
  end
end
