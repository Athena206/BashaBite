class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.text :ingredients, null: false
      t.text :instructions, null: false

      t.timestamps
    end

    add_index :recipes, :title, unique: true
  end
end
