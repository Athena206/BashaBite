class RecipeSearch
  STOP_WORDS = %w[
    a an and are can could do for give how i in is make me of please recipe the to what
  ].freeze

  def self.call(query)
    terms = query.to_s.downcase.scan(/[[:alnum:]]+/).reject { |term| STOP_WORDS.include?(term) }
    return if terms.empty?

    match = Recipe.all
      .map { |recipe| [recipe, score(recipe, terms)] }
      .select { |_recipe, score| score.positive? }
      .max_by { |recipe, score| [score, recipe.title.length * -1] }

    return unless match && match.last >= 2

    match.first
  end

  def self.score(recipe, terms)
    title = recipe.title.downcase
    ingredients = recipe.ingredients.downcase

    terms.sum do |term|
      title.include?(term) ? 3 : (ingredients.include?(term) ? 1 : 0)
    end
  end
  private_class_method :score
end
