module ToFromAddressable
  extend ActiveSupport::Concern

  included do
    after_validation :geocode_to, if: ->(obj){ (obj.to_address_changed? ||
        obj.to_city_changed? ||
        obj.to_state_changed?) &&
        !(obj.to_latitude_changed? || obj.to_longitude_changed?)
    }

    after_validation :geocode_from, if: ->(obj){ (obj.from_address_changed? ||
        obj.from_city_changed? ||
        obj.from_state_changed?) &&
        !(obj.from_latitude_changed? ||
            obj.from_longitude_changed?)
    }
  end

  def full_to_address
    [self.to_address, self.to_city, self.to_state].compact.reject(&:empty?).join(', ')
  end

  def full_from_address
    [self.from_address, self.from_city, self.from_state].compact.reject(&:empty?).join(', ')
  end

  private

  def geocode_to
    to_coordinates = Geocoder.coordinates(self.full_to_address)
    unless to_coordinates.nil?
      self.to_latitude = to_coordinates.first
      self.to_longitude = to_coordinates.second
    end
  end

  def geocode_from
    from_coordinates = Geocoder.coordinates(self.full_from_address)
    unless from_coordinates.nil?
      self.from_latitude = from_coordinates.first
      self.from_longitude = from_coordinates.second
    end
  end
end