class RideZone < ApplicationRecord
  resourcify

  has_many :conversations
  has_many :messages

  validates_presence_of :name

  def drivers
    User.with_role(:driver, self)
  end

  def dispatchers
    User.with_role(:dispatcher, self)
  end

end
