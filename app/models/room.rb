class Room < ApplicationRecord
  enum :status, { waiting: 0, playing: 1, finished: 2 }
  has_many :room_players
  has_many :users, through: :room_players
  has_many :turns
end
