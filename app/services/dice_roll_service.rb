class DiceRollService
  def initialize(room)
    @room = room
  end

  def roll_for(player)
    dice = Dice.new
    player.update!(dice_roll: dice.roll)
    player.dice_roll
  end
end
