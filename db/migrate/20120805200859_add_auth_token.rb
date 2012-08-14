class AddAuthToken < ActiveRecord::Migration
  def up
    change_table :spree_user_authentications do |t|
      t.string :auth_token
      t.timestamp :expires_at
      t.boolean :expires
    end
  end
  
  def down
    remove_column :spree_user_authentications, :auth_token
    remove_column :spree_user_authentications, :expires_at
    remove_column :spree_user_authentications, :expires
  end
end
