class AddAuthenticationTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :auth_token, :string, default: ""
  end
end
