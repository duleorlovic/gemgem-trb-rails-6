class User < ApplicationRecord
  serialize :auth_meta_data

  has_many :authorships, dependent: :destroy
  has_many :things, through: :authorships
  has_many :comments, dependent: :destroy
end
