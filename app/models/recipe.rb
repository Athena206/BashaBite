class Recipe < ApplicationRecord
  CUISINES = ["Chinese", "North Indian", "South Indian", "Bengali", "Gujarati", "Marathi", "Other"].freeze
  CUISINE_IMAGES = {
    "Chinese" => "photo-1569718212165-3a8278d5f624",
    "North Indian" => "photo-1585937421612-70a008356fbe",
    "South Indian" => "photo-1668236543090-82eba5ee5976",
    "Bengali" => "photo-1547592180-85f173990554",
    "Gujarati" => "photo-1512621776951-a57141f2eefd",
    "Marathi" => "photo-1540189549336-e6e99c3679fe",
    "Other" => "photo-1540189549336-e6e99c3679fe"
  }.freeze
  CUISINE_EMOJIS = {
    "Chinese" => "🥢",
    "North Indian" => "🫓",
    "South Indian" => "🥥",
    "Bengali" => "🐟",
    "Gujarati" => "🍋",
    "Marathi" => "🥜",
    "Other" => "🍽️"
  }.freeze

  validates :title, :ingredients, :instructions, presence: true
  validates :cuisine, inclusion: { in: CUISINES }

  scope :alphabetical, -> { order(:title) }
  scope :search_text, ->(query) {
    term = sanitize_sql_like(query.to_s.downcase)
    pattern = "%#{term}%"
    where(
      "LOWER(title) LIKE :pattern OR LOWER(cuisine) LIKE :pattern OR " \
      "LOWER(ingredients) LIKE :pattern OR LOWER(instructions) LIKE :pattern",
      pattern: pattern
    )
  }

  def instruction_steps
    instructions.lines.map(&:strip).reject(&:blank?)
  end

  def narration_text
    [
      title,
      "Ingredients: #{ingredients.lines.map(&:strip).reject(&:blank?).join(', ')}.",
      "Instructions: #{instruction_steps.join(' ')}"
    ].join("\n")
  end

  def food_image_url
    image_id = CUISINE_IMAGES.fetch(cuisine, CUISINE_IMAGES.fetch("Other"))
    "https://images.unsplash.com/#{image_id}?auto=format&fit=crop&w=960&q=82"
  end

  def cuisine_emoji
    CUISINE_EMOJIS.fetch(cuisine, CUISINE_EMOJIS.fetch("Other"))
  end
end
