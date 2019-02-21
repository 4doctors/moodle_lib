defmodule MoodleLib.Client do
  alias MoodleLib.User

  def create_user(user_params) do
    user_params
    |> build_user()
    |> prepare_user()
    |> to_querystring()
    |> Map.put(:wsfunction, :core_user_create_users)
    |> build_uri()
    |> HTTPoison.get!()
    |> process_user_created()
  end

  def delete_user(id) do
    %{"userids[0]" => id}
    |> Map.put(:wsfunction, :core_user_delete_users)
    |> build_uri()
    |> HTTPoison.get!()
    |> process_user_deleted()
  end

  def build_user(user_params) do
    user_params
    |> group_customfields()
    |> (&struct(User, &1)).()
  end

  def get_user(id) do
    %{
      "criteria[0][key]" => "id",
      "criteria[0][value]" => id
    }
    |> Map.put(:wsfunction, :core_user_get_users)
    |> build_uri()
    |> HTTPoison.get!()
    |> process_got_user()
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

  defp build_uri(params) do
    Application.get_env(:moodle_lib, :base_url)
    |> URI.parse()
    |> Map.put(:query, query_params(params))
    |> to_string()
  end

  defp process_user_created(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      [%{id: _} = user] ->
        {:ok, user}

      _ ->
        {:error, message: "Error creating the username"}
    end
  end

  defp process_user_deleted(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      nil ->
        {:ok, message: "User successfully deleted"}

      _ ->
        {:error, message: "Error deleting the username"}
    end
  end

  defp process_got_user(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      %{users: [%{id: _} = user]} ->
        {:ok, user}

      %{users: []} ->
        {:error, message: "User not found"}
    end
  end

  defp query_params(user) do
    user
    |> Map.put(:wstoken, Application.get_env(:moodle_lib, :token))
    |> Map.put(:moodlewsrestformat, :json)
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end

  defp flatten_custom_fields(params) do
    params.customfields
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {{k, v}, idx}, acc ->
      acc
      |> Map.put("customfields][#{idx}][type", k)
      |> Map.put("customfields][#{idx}][value", v)
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
