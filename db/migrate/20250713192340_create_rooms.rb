class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :status
      t.integer :current_turn

      t.timestamps
    end
  end
end
