defmodule MoodleLib.Client do
  alias MoodleLib.User

  def create_user(user_params) do
    user_params
    |> build_user()
    |> prepare_user()
    |> to_querystring()
    |> build_uri()
    |> HTTPoison.get!()
    |> process_request()
  end

  def build_user(user_params) do
    user_params
    |> group_customfields()
    |> (&struct(User, &1)).()
  end

  defp prepare_user(user) do
    user
    |> Map.from_struct()
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  defp to_querystring(user) do
    user
    |> flatten_custom_fields()
    |> Map.put(:createpassword, 1)
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, "users[0][#{k}]", v)
    end)
  end

  defp build_uri(user) do
    Application.get_env(:moodle_lib, :base_url)
    |> URI.parse()
    |> Map.put(:query, query_params(user))
    |> to_string()
  end

  defp process_request(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!()
    case parsed_body do
      [%{"id" => id, "username" => username}] ->
        {:ok, %{id: id, username: username}}
      _ ->
        {:error, message: "Error creating the username"}
    end
  end

  defp query_params(user) do
    user
    |> Map.put(:wstoken, Application.get_env(:moodle_lib, :token))
    |> Map.put(:wsfunction, :core_user_create_users)
    |> Map.put(:moodlewsrestformat, :json)
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end

  defp flatten_custom_fields(params) do
    params.customfields
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {{k, v}, idx}, acc ->
      acc = Map.put(acc, "customfields][#{idx}][type", "#{k}")
      Map.put(acc, "customfields][#{idx}][value", v)
    end)
    |> Map.merge(params)
    |> Map.delete(:customfields)
  end

  defp group_customfields(params) do
    user_keys = Map.keys(%User{})
    params_keys = Map.keys(params)
    new_params = params_keys |> Enum.filter(&(!Enum.member?(user_keys, &1)))

    customfields =
      new_params
      |> Enum.reduce(%{}, fn el, acc ->
        Map.put(acc, el, params[el])
      end)

    Map.put(params, :customfields, customfields)
  end
end
