class AddAuthMetaDataToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :auth_meta_data, :text
  end
end
