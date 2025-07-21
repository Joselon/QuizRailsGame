class GameManager
  def initialize(room)
    @room = room
  end

  def start_turn_order_phase!
    @room.update(status: :rolling_for_order, current_turn: nil)
    @room.room_players.update_all(dice_roll: nil)
  end

    def start_tiebreak_phase!
    @room.update(status: :tiebreak_for_order)
    # TODO:clean dice rest of players
  end

  def next_turn!
    players = @room.room_players.order(:turn_order)
    return if players.empty?

    current_index = players.find_index { |p| p.turn_order == @room.current_turn }
    next_index = current_index ? (current_index + 1) % players.size : 0

    @room.update(current_turn: players[next_index].turn_order)
  end

  def turn_order_decided?
    @room.room_players.all? { |p| p.dice_roll.present? } && @room.status != "tiebreak_for_order"
  end
end
