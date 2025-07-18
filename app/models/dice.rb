class Dice
  DEFAULT_SIDES = 6

  attr_reader :sides

  def initialize(sides = DEFAULT_SIDES)
    @sides = sides
  end

  def roll
    rand(1..sides)
  end
end
