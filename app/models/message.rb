class Message < ApplicationRecord
  belongs_to :ride_zone
  
  enum status: { active: 0, inprogress: 1, closed: 2 }

end
