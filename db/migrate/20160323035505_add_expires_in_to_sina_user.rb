class AddExpiresInToSinaUser < ActiveRecord::Migration
  def change
    add_column :sina_users, :expires_in, :string
  end
end
