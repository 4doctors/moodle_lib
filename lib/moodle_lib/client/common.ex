defmodule MoodleLib.Client.Common do
  def process_request(params) do
    params
    |> build_uri()
    |> HTTPoison.get!()
    |> extract_body()
  end

  defp extract_body(%HTTPoison.Response{body: body}) do
    body |> Jason.decode!(keys: :atoms)
  end

  defp build_uri(params) do
    Application.get_env(:moodle_lib, :base_url)
    |> URI.parse()
    |> Map.put(:query, query_params(params))
    |> to_string()
  end

  defp query_params(user) do
    user
    |> Map.put(:wstoken, Application.get_env(:moodle_lib, :token))
    |> Map.put(:moodlewsrestformat, :json)
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end
end
