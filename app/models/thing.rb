class Thing < ApplicationRecord
  scope :latest, -> { all.limit(9).order(id: :desc) }
end
