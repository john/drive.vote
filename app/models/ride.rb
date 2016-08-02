class Ride < ApplicationRecord
  belongs_to :campaign
  belongs_to :ride_zone
  
  has_many :messages
  
  enum status: { active: 0, inprogress: 1, closed: 2 }
  
  validates_presence_of :owner_id
  
end
