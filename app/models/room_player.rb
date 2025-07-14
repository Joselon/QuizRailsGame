class RoomPlayer < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :turns
end
