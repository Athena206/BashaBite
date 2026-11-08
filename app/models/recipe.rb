class Recipe < ApplicationRecord
  CUISINES = ["Chinese", "North Indian", "South Indian", "Bengali", "Gujarati", "Marathi", "Other"].freeze

  validates :title, :ingredients, :instructions, presence: true
  validates :cuisine, inclusion: { in: CUISINES }

  scope :alphabetical, -> { order(:title) }

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
end
