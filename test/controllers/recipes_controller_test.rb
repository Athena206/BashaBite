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
    assert_select "title", "Rasoi Tale — recipes with a little soul"
    assert_select ".brand[aria-label='Rasoi Tale home']"
    assert_select "#gujarati-recipes"
    assert_select "#chinese-recipes"
    assert_select ".cuisine-nav a", count: 2
    assert_select ".recipe-image", minimum: 2
    assert_select "form.recipe-search"
    assert_select "input[name=q]"
  end

  test "searches recipes by dish name, cuisine, ingredient, or instruction" do
    Recipe.create!(
      title: "Paneer Tikka",
      cuisine: "North Indian",
      ingredients: "Paneer, yogurt, spices",
      instructions: "Grill until golden."
    )
    Recipe.create!(
      title: "Lemon Rice",
      cuisine: "South Indian",
      ingredients: "Rice, lemon, peanuts",
      instructions: "Toss with curry leaves."
    )

    get root_path, params: { q: "paneer" }

    assert_response :success
    assert_select ".recipe-card h3 a", text: "Paneer Tikka"
    assert_select ".recipe-card h3 a", count: 1
    assert_select "input[name=q][value=paneer]"
  end

  test "shows a helpful empty state when a text search has no matches" do
    get root_path, params: { q: "unicorn noodles" }

    assert_response :success
    assert_select ".search-empty"
    assert_select ".search-empty a[href='/']", text: "Show all recipes"
  end

  test "filters recipes by dietary preference and keeps text search" do
    vegetarian = Recipe.create!(
      title: "Veg Noodles",
      cuisine: "Chinese",
      ingredients: "Noodles, vegetables",
      instructions: "Stir-fry."
    )
    non_vegetarian = Recipe.create!(
      title: "Chicken Noodles",
      cuisine: "Chinese",
      diet_type: "non_veg",
      ingredients: "Noodles, chicken",
      instructions: "Stir-fry."
    )

    get root_path, params: { q: "noodles", diet: "non_veg" }

    assert_response :success
    assert_select ".recipe-card h3 a", text: non_vegetarian.title
    assert_select ".recipe-card h3 a", count: 1
    assert_select "input[name=q][value=noodles]"
    assert_select "select[name=diet] option[selected][value=non_veg]"
    assert_select ".diet-non_veg", text: "Non-veg"
    assert_not_includes response.body, vegetarian.title
  end

  test "shows an empty state when a dietary filter has no matches" do
    get root_path, params: { diet: "non_veg" }

    assert_response :success
    assert_select ".search-empty"
    assert_select ".search-empty a[href='/']", text: "Show all recipes"
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
