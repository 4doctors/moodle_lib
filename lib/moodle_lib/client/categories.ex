defmodule MoodleLib.Client.Categories do
  import MoodleLib.Client.Common, only: [process_request: 2]

  def get_categories do
    %{}
    |> process_request(:core_course_get_categories)
    |> handle_got_categories()
  end

  defp handle_got_categories(request_body) do
    case request_body do
      [_ | _] = categories ->
        {:ok, categories}

      _ ->
        {:error, message: "There was an error retrieving the list of categories"}
    end
  end
end
