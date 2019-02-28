defmodule MoodleLib.Client.Users do
  alias MoodleLib.User

  import MoodleLib.Client.Common, only: [process_request: 2]

  def create_user(user_params) do
    user_params
    |> build_user()
    |> prepare_user()
    |> to_querystring()
    |> process_request(:core_user_create_users)
    |> handle_user_created()
  end

  def delete_user(id) do
    %{"userids[0]" => id}
    |> process_request(:core_user_delete_users)
    |> handle_user_deleted()
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
    |> process_request(:core_user_get_users)
    |> handle_got_user()
  end

  def get_users(ids) do
    ids
    |> Enum.with_index()
    |> Enum.map(fn {id, idx} -> {"values[#{idx}]", id} end)
    |> Map.new()
    |> Map.put(:field, :id)
    |> process_request(:core_user_get_users_by_field)
    |> handle_got_users()
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

  defp handle_user_created(response_body) do
    case response_body do
      [%{id: _} = user] ->
        {:ok, user}

      _ ->
        {:error, message: "Error creating the username"}
    end
  end

  defp handle_user_deleted(response_body) do
    case response_body do
      nil ->
        {:ok, message: "User successfully deleted"}

      _ ->
        {:error, message: "Error deleting the username"}
    end
  end

  defp handle_got_user(response_body) do
    case response_body do
      %{users: [%{id: _} = user]} ->
        {:ok, user}

      %{users: []} ->
        {:error, message: "User not found"}
    end
  end

  defp handle_got_users(response_body) do
    case response_body do
      [_ | _] = users ->
        {:ok, users}

      [] ->
        {:error, message: "No users found"}
    end
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
