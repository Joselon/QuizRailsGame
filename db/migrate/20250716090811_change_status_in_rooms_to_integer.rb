class ChangeStatusInRoomsToInteger < ActiveRecord::Migration[8.0]
  def change
    remove_column :rooms, :status, :string
    add_column :rooms, :status, :integer, default: 0, null: false
  end
end
