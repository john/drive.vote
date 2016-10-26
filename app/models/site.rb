class Site < ApplicationRecord
  validates_inclusion_of :singleton_guard, in: [0]
  validates_inclusion_of :update_location_interval, in: (10..300)
  validates_inclusion_of :waiting_rides_interval, in: (10..300)

  def self.instance
    site = first
    unless site
      site = Site.new
      site.singleton_guard = 0
      site.save!
    end
    site
  end
end
