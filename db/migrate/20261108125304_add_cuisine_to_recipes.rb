class AddCuisineToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :cuisine, :string, null: false, default: "Other"
    add_index :recipes, :cuisine
  end
end
