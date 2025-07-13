class CreateRoomPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :room_players do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.integer :score
      t.integer :turn_order

      t.timestamps
    end
  end
end
