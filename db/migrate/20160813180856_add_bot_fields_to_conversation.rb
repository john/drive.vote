class AddBotFieldsToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :special_requests, :text
    add_column :conversations, :additional_passengers, :integer
    add_column :conversations, :bot_counter, :integer, default: 0
    add_column :conversations, :ignore_prior_ride, :boolean
    add_column :conversations, :from_confirmed, :boolean
    add_column :conversations, :to_confirmed, :boolean
    add_column :conversations, :time_confirmed, :boolean
    add_column :ride_zones, :utc_offset, :integer
    add_column :rides, :from_city, :string
    add_column :rides, :to_city, :string
  end
end
