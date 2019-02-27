defmodule MoodleLib.Client.Categories do
  alias MoodleLib.Client.Common

  def get_categories do
    %{}
    |> Map.put(:wsfunction, :core_course_get_categories)
    |> Common.build_uri()
    |> HTTPoison.get!()
    |> handle_got_categories()
  end

  defp handle_got_categories(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      [_ | _] = categories ->
        {:ok, categories}

      _ ->
        {:error, message: "There was an error retrieving the list of categories"}
    end
  end
end
