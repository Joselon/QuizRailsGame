class AddDiceRollToRoomPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :room_players, :dice_roll, :integer
  end
end
