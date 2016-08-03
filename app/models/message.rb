class Message < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :conversation

  enum status: { unassigned: 0, inprogress: 1, closed: 2 }

  # # scope by messagestatuses
  # scope :unassigned, -> { where(status: :unassigned) }

end
