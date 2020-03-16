class CreateThings < ActiveRecord::Migration[6.0]
  def change
    create_table :things do |t|
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end
