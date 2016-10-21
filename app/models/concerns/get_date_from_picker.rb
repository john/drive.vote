module GetDateFromPicker
  extend ActiveSupport::Concern

  def transfer_date_to_pickup_at(time_zone, pickup_day, pickup_time)
    if self.pickup_at.blank?

      # TODO: ditch Chronic?
      if Chronic.parse(pickup_day) && Chronic.parse(pickup_time)

        #concatenated_time = Chronic.parse( [pickup_day, pickup_time].join(', ') ) # will get stored in UTC as is...


        # origin_time = Time.use_zone(origin_time_zone) do Time.zone.parse( [pickup_day, pickup_time].join(', ') ); end

        origin_time = Time.use_zone(origin_time_zone) do Chronic.parse( [pickup_day, pickup_time].join(', ') ); end


        self.pickup_at =  origin_time
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