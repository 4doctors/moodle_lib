defmodule MoodleLibTest do
  use ExUnit.Case
  doctest MoodleLib

  test "greets the world" do
    assert MoodleLib.hello() == :world
  end
end
