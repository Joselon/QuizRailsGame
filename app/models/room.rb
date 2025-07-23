class Room < ApplicationRecord
  enum :status, { waiting: 0,
                  rolling_for_order: 1,
                  tiebreak_for_order: 2,
                  playing: 3,
                  finished: 4 }

  has_many :room_players, dependent: :destroy
  has_many :users, through: :room_players
  has_many :turns, dependent: :destroy

  def current_player
    return nil if current_turn.nil?
    room_players.find_by(turn_order: current_turn)
  end
end
