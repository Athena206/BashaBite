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
end
