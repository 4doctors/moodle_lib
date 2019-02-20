defmodule MoodleLib.Client do
  alias MoodleLib.User
  # http://localhost:8080/webservice/rest/server.php?
  # wstoken={{TOKEN}}&
  # wsfunction=core_user_create_users&
  # moodlewsrestformat=json&
  # users[0][username]=user2&
  # users[0][password]=Passw0rd-&
  # users[0][firstname]=Example&
  # users[0][lastname]=User&
  # users[0][email]=user3@example.com&
  # users[0][customfields][0][type]=Patrocinador&
  # users[0][customfields][0][value]=Alter&
  # users[0][customfields][1][type]=NIF&
  # users[0][customfields][1][value]=123456789Z
  def build_user(user_params) do
      user_params
      |> group_customfields()
      |> (&struct(User, &1)).()
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

  defp url do
    "http://localhost:8080/webservice/rest/server.php"
  end
end
