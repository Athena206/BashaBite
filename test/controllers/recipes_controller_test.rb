require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  test "groups recipes into cuisine sections" do
    Recipe.create!(
      title: "Test Dhokla",
      cuisine: "Gujarati",
      ingredients: "Gram flour",
      instructions: "Steam it."
    )
    Recipe.create!(
      title: "Test Dumplings",
      cuisine: "Chinese",
      ingredients: "Flour",
      instructions: "Steam them."
    )

    get root_path

    assert_response :success
    assert_select "#gujarati-recipes"
    assert_select "#chinese-recipes"
    assert_select ".cuisine-nav a", count: 2
  end

  test "shows an audio player that fetches recipe audio from Rails" do
    recipe = Recipe.create!(
      title: "Test Sambar",
      cuisine: "South Indian",
      ingredients: "Lentils",
      instructions: "Simmer it."
    )

    get recipe_path(recipe)

    assert_response :success
    assert_select "button[data-audio-play]", "Preparing voice…"
    assert_select "audio[data-gnani-audio][data-audio-url=?]", audio_recipe_path(recipe)
  end
end
