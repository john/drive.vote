class RemoveMessageFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :messages, :status, :integer, default: 0
    remove_column :messages, :to_city, :string, default: ''
    remove_column :messages, :to_state, :string, default: ''
    remove_column :messages, :to_country, :string, default: ''
    remove_column :messages, :to_zip, :string, default: ''
    remove_column :messages, :from_city, :string, default: ''
    remove_column :messages, :from_state, :string, default: ''
    remove_column :messages, :from_country, :string, default: ''
    remove_column :messages, :from_zip, :string, default: ''
  end
end
