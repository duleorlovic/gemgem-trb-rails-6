class Thing < ApplicationRecord
  scope :latest, -> { all.limit(9).order(id: :desc) }

  has_many :comments, dependent: :destroy
end
