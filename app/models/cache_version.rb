class CacheVersion < ApplicationRecord
  def self.for(name)
    where(name: name).first or create(name: name)
  end

  # called in AS::Cache#retrieve_cache_key
  def cache_key
    updated_at
  end

  def expire!
    update_attribute(:updated_at, (updated_at || Time.now) + 1.second)
  end
end
