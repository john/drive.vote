class RemoveUserTypeFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :user_type, :integer
  end
end
