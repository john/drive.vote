module GetDateFromPicker
  extend ActiveSupport::Concern

  def transfer_date_to_pickup_at(time_zone, pickup_day, pickup_time)
    if self.pickup_at.blank?

      # TODO: ditch Chronic?
      if Chronic.parse(pickup_day) && Chronic.parse(pickup_time)

        # Because this is simply the parsed version of the date/time they entered themselves,
        # can we safely assume it already is in the local timezone, and we don't need to manipulate it?
        concatenated_time = Chronic.parse( [pickup_day, pickup_time].join(', ') )
        self.pickup_at =  concatenated_time
        return true
      else
        # TODO: normalize to pickup_at when possible
        if self.class == Conversation
          self.errors.add(:pickup_time, :invalid)
        else
          self.errors.add(:pickup_at, :invalid)
        end
        return false
      end
    else
      return false
    end
  end

end