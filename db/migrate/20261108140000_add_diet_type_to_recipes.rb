class AddDietTypeToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :diet_type, :string, null: false, default: "veg"
    add_index :recipes, :diet_type
  end
end
