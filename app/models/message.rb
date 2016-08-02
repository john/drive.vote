class Message < ApplicationRecord
  belongs_to :ride_zone
  has_one :ride
  
  enum status: { unassigned: 0, inprogress: 1, closed: 2 }
  
  # # scope by messagestatuses
  # scope :unassigned, -> { where(status: :unassigned) }

end
