class AddAvailableToUser < ActiveRecord::Migration[5.0]

  def change
    add_column :users, :available, :boolean, null: false, default: false
  end

end
