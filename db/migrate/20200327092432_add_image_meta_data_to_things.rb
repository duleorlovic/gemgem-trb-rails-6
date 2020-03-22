class AddImageMetaDataToThings < ActiveRecord::Migration[6.0]
  def change
    add_column :things, :image_meta_data, :text
  end
end
