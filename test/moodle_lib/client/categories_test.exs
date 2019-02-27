defmodule MoodleLib.Client.CategoriesTest do
  use ExUnit.Case

  alias MoodleLib.Client.Categories

  test "it can retrieve the list of all categories" do
    {:ok, categories} = Categories.get_categories()

    assert Enum.count(categories) > 0
  end
end
