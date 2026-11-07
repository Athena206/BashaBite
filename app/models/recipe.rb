class Recipe < ApplicationRecord
  validates :title, :ingredients, :instructions, presence: true

  scope :alphabetical, -> { order(:title) }

  def instruction_steps
    instructions.lines.map(&:strip).reject(&:blank?)
  end
end
