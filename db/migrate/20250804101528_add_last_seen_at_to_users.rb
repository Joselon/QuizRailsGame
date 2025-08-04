class AddLastSeenAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :last_seen_at, :datetime
  end
end
