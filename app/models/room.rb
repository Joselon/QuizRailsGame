class Room < ApplicationRecord
  has_many :room_players
  has_many :users, through: :room_players
  has_many :turns

  enum status: { waiting: 0, playing: 1, finished: 2 }
end
