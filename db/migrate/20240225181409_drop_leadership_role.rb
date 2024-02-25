class DropLeadershipRole < ActiveRecord::Migration[7.1]
  def change
    drop_table :leadership_roles
  end
end
