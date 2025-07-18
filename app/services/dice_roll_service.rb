class DiceRollService
  def initialize(room)
    @room = room
  end

  def roll_for(player)
    dice = Dice.new
    player.update(dice_roll: dice.roll)
    check_results
  end

  private

  def check_results
    players = @room.room_players
    return unless players.all? { |p| p.dice_roll.present? }

    max_value = players.map(&:dice_roll).max
    top_players = players.select { |p| p.dice_roll == max_value }

    if top_players.size == 1
      @room.update!(current_turn: top_players.first.turn_order, status: :playing)
    else
      @room.update!(status: :tiebreak_for_order)
      (players - top_players).each { |p| p.update(dice_roll: nil) }
    end
  end
end
