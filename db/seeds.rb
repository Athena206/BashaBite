recipes = [
  {
    title: "Aloo Posto",
    ingredients: <<~INGREDIENTS,
      4 medium potatoes, peeled and cubed
      4 tablespoons poppy seeds
      2 green chilies
      1/2 teaspoon nigella seeds
      3 tablespoons mustard oil
      Salt to taste
      1/2 cup water
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Soak the poppy seeds in warm water for 20 minutes, then grind them with one green chili into a smooth paste.
      Heat mustard oil in a pan until it just begins to smoke. Add nigella seeds and the remaining green chili.
      Add the potatoes and salt. Stir to coat, cover, and cook over medium-low heat for 8 minutes.
      Stir in the poppy seed paste and water. Cover and simmer until the potatoes are tender and the sauce is thick.
      Serve warm with steamed rice.
    INSTRUCTIONS
  },
  {
    title: "Masala Dosa",
    ingredients: <<~INGREDIENTS,
      4 cups dosa batter
      4 medium potatoes, boiled and roughly mashed
      1 onion, thinly sliced
      1 teaspoon mustard seeds
      8 curry leaves
      1/2 teaspoon turmeric
      2 tablespoons oil
      Salt to taste
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Heat oil in a pan. Add mustard seeds and curry leaves; let the seeds pop.
      Add onion and cook until soft. Stir in turmeric, potatoes, salt, and a splash of water.
      Cook the potato filling for 3 minutes, then set it aside.
      Spread a ladle of dosa batter into a thin circle on a hot, lightly oiled pan.
      Cook until crisp, place potato filling in the center, fold, and serve hot with chutney.
    INSTRUCTIONS
  },
  {
    title: "Gujarati Kadhi",
    ingredients: <<~INGREDIENTS,
      1 cup plain yogurt
      3 tablespoons gram flour
      3 cups water
      1 tablespoon jaggery or sugar
      1/2 teaspoon turmeric
      1 teaspoon mustard seeds
      1/2 teaspoon cumin seeds
      1 dried red chili
      8 curry leaves
      1 tablespoon ghee
      Salt to taste
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Whisk yogurt, gram flour, turmeric, salt, and water until smooth with no lumps.
      Pour the mixture into a pot and bring to a gentle boil, stirring often.
      Add jaggery and simmer on low heat for 12 minutes, stirring occasionally.
      Heat ghee in a small pan. Add mustard seeds, cumin, dried chili, and curry leaves.
      Pour the hot tempering into the kadhi and serve with rice.
    INSTRUCTIONS
  },
  {
    title: "Poha",
    ingredients: <<~INGREDIENTS,
      2 cups thick flattened rice
      1 small onion, chopped
      1 green chili, chopped
      1/2 teaspoon mustard seeds
      8 curry leaves
      1/4 cup roasted peanuts
      1/2 teaspoon turmeric
      1 tablespoon oil
      1 tablespoon lemon juice
      Salt to taste
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Rinse the flattened rice briefly in a sieve, drain well, and let it soften for 5 minutes.
      Heat oil in a pan. Add mustard seeds and curry leaves, then stir in the peanuts.
      Add onion and green chili and cook until the onion softens.
      Mix in turmeric and salt, then gently fold in the softened flattened rice.
      Cover and steam on low heat for 3 minutes. Finish with lemon juice and serve warm.
    INSTRUCTIONS
  },
  {
    title: "Rajma",
    ingredients: <<~INGREDIENTS,
      2 cups cooked kidney beans
      2 onions, finely chopped
      2 tomatoes, pureed
      1 tablespoon ginger-garlic paste
      1 teaspoon cumin seeds
      1 teaspoon ground coriander
      1/2 teaspoon turmeric
      1 teaspoon garam masala
      2 tablespoons oil
      Salt to taste
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Heat oil in a heavy pot. Add cumin seeds and let them sizzle.
      Add onions and cook until golden, then stir in the ginger-garlic paste.
      Add tomato puree, coriander, turmeric, and salt. Cook until the oil separates.
      Stir in the kidney beans and 2 cups of cooking liquid or water.
      Simmer covered for 25 minutes, lightly mashing a few beans to thicken the gravy.
      Stir in garam masala and serve with rice.
    INSTRUCTIONS
  },
  {
    title: "Sambar",
    ingredients: <<~INGREDIENTS,
      1 cup toor dal
      1 cup mixed vegetables, chopped
      1 small onion, chopped
      1 tomato, chopped
      2 tablespoons tamarind pulp
      2 tablespoons sambar powder
      1/2 teaspoon mustard seeds
      8 curry leaves
      1 tablespoon oil
      Salt to taste
    INGREDIENTS
    instructions: <<~INSTRUCTIONS
      Rinse the toor dal and pressure cook with 3 cups water until soft. Mash until smooth.
      Boil the vegetables and onion in a pot with enough water to cover until nearly tender.
      Add tomato, tamarind pulp, sambar powder, and salt. Simmer for 8 minutes.
      Stir in the cooked dal and add water to reach your preferred consistency. Simmer for 5 minutes.
      Heat oil in a small pan. Add mustard seeds and curry leaves, then pour the tempering over the sambar.
      Serve hot with rice or idli.
    INSTRUCTIONS
  }
]

recipes.each do |attributes|
  Recipe.find_or_initialize_by(title: attributes[:title]).update!(attributes)
end
