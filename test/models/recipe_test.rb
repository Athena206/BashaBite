require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "requires a title, ingredients, and instructions" do
    recipe = Recipe.new

    assert_not recipe.valid?
    assert_includes recipe.errors.attribute_names, :title
    assert_includes recipe.errors.attribute_names, :ingredients
    assert_includes recipe.errors.attribute_names, :instructions
  end

  test "splits instructions into display steps" do
    recipe = Recipe.new(instructions: "First step.\n\nSecond step.")

    assert_equal ["First step.", "Second step."], recipe.instruction_steps
  end

  test "requires a supported cuisine" do
    recipe = Recipe.new(title: "Test", ingredients: "Rice", instructions: "Cook it.", cuisine: "Unknown")

    assert_not recipe.valid?
    assert_includes recipe.errors.attribute_names, :cuisine
  end

  test "builds narration from the recipe title, ingredients, and instructions" do
    recipe = Recipe.new(
      title: "Masala Dosa",
      ingredients: "Dosa batter\nPotatoes\n",
      instructions: "Prepare the filling.\nCook the dosa."
    )

    assert_equal(
      "Masala Dosa\nIngredients: Dosa batter, Potatoes.\nInstructions: Prepare the filling. Cook the dosa.",
      recipe.narration_text
    )
  end
end
