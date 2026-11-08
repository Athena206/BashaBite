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

  test "defaults recipes to vegetarian and labels both dietary types" do
    recipe = Recipe.new

    assert_equal "veg", recipe.diet_type
    assert_equal "Veg", recipe.diet_label

    recipe.diet_type = "non_veg"
    assert_equal "Non-veg", recipe.diet_label
  end

  test "requires a supported dietary type" do
    recipe = Recipe.new(title: "Test", ingredients: "Rice", instructions: "Cook it.", diet_type: "unknown")

    assert_not recipe.valid?
    assert_includes recipe.errors.attribute_names, :diet_type
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

  test "provides cuisine-specific food imagery and icons" do
    recipe = Recipe.new(cuisine: "South Indian")

    assert_includes recipe.food_image_url, "images.unsplash.com"
    assert_includes recipe.food_image_url, Recipe::CUISINE_IMAGES["South Indian"]
    assert_equal "🥥", recipe.cuisine_emoji
  end

  test "searches recipe titles, cuisines, ingredients, and instructions case insensitively" do
    recipe = Recipe.create!(
      title: "Paneer Tikka",
      cuisine: "North Indian",
      ingredients: "Paneer, yogurt, spices",
      instructions: "Grill until golden."
    )

    assert_equal [recipe], Recipe.search_text("PANEER").to_a
    assert_equal [recipe], Recipe.search_text("north indian").to_a
    assert_equal [recipe], Recipe.search_text("golden").to_a
  end
end
