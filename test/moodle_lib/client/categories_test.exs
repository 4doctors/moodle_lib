defmodule MoodleLib.Client.CategoriesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MoodleLib.Client.Categories

  test "it can retrieve the list of all categories" do
    use_cassette "get_categories", match_requests_on: [:query] do
      {:ok, categories} = Categories.get_categories()

      assert Enum.count(categories) > 0
    end
  end
end
