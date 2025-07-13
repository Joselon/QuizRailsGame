class Turn < ApplicationRecord
  belongs_to :room
  belongs_to :room_player
  belongs_to :question
end
