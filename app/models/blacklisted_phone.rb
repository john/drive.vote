class BlacklistedPhone < ApplicationRecord
  belongs_to :conversation

  def self.has_voter_phone? voter_phone
    self.where(phone: voter_phone).empty? ? false : true
  end
end
