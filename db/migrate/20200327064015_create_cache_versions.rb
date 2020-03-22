class CreateCacheVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :cache_versions do |t|
      t.string :name
      t.datetime :updated_at
    end
  end
end
