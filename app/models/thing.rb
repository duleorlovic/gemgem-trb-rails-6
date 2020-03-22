class Thing < ApplicationRecord
  serialize :image_meta_data

  has_many :authorships
  has_many :users, through: :authorships

  has_many :comments, -> { order(created_at: :desc) }, dependent: :destroy

  scope :latest, -> { all.limit(9).order(id: :desc) }
end
