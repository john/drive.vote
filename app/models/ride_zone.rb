class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages

end
