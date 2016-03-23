class AddIndexToSinaUser < ActiveRecord::Migration
  def change
    add_index :sina_users, :uid, unique: true
  end
end
