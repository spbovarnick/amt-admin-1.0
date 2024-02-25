class RemoveUserColumns < ActiveRecord::Migration[7.1]
  def change
    remove_columns :users, :archivist, :board_member
  end
end
