class CreateSinaUsers < ActiveRecord::Migration
  def change
    create_table :sina_users do |t|
      t.string :username
      t.string :access_token
      t.string :uid

      t.timestamps null: false
    end
  end
end
