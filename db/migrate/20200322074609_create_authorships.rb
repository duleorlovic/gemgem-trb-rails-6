class CreateAuthorships < ActiveRecord::Migration[6.0]
  def change
    create_table :authorships do |t|
      t.references :thing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :confirmed

      t.timestamps
    end
  end
end
