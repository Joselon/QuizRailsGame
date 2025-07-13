class CreateTurns < ActiveRecord::Migration[8.0]
  def change
    create_table :turns do |t|
      t.references :room, null: false, foreign_key: true
      t.references :room_player, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :answer
      t.boolean :correct

      t.timestamps
    end
  end
end
