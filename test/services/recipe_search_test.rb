require "test_helper"

class RecipeSearchTest < ActiveSupport::TestCase
  test "matches a recipe title while ignoring question words" do
    recipe = Recipe.create!(
      title: "Aloo Posto",
      ingredients: "Potatoes, poppy seeds, salt",
      instructions: "Cook the potatoes."
    )

    assert_equal recipe, RecipeSearch.call("How do I make Aloo Posto?")
  end

  test "does not choose a recipe based on only one ingredient keyword" do
    Recipe.create!(
      title: "Gujarati Kadhi",
      ingredients: "Yogurt, gram flour, jaggery or sugar",
      instructions: "Simmer the kadhi."
    )

    assert_nil RecipeSearch.call("What is the ratio of sugar to milk?")
  end
end
