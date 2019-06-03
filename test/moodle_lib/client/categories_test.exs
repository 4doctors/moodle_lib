defmodule MoodleLib.Client.CategoriesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.Client.Categories

  test "it can retrieve the list of all categories" do
    # right now categories are preseeded on the DB: category 1, category 1.1 and category 2
    use_cassette "get_categories", match_requests_on: [:query] do
      {:ok, categories} = Categories.get_categories()

      assert Enum.any?(categories, &(&1.name == "category 1"))
      assert Enum.any?(categories, &(&1.name == "category 1.1"))
      assert Enum.any?(categories, &(&1.name == "category 2"))
      assert Enum.count(categories) > 0
    end
  end
end
