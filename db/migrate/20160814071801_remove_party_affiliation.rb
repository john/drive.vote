class RemovePartyAffiliation < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :party_affiliation, :integer
  end
end
