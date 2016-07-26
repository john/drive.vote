class Message < ApplicationRecord
  belongs_to :ride_area
  
  enum status: { active: 0, working: 1, closed: 2 }

end
