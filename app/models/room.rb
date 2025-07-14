class Room < ApplicationRecord
  has_many :room_players
  has_many :users, through: :room_players
  has_many :turns
end
