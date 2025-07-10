class AddSnapshotRecipientToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :snapshot_recipient, :boolean, :default => false
  end
end
