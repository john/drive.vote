class TimeZoneUtils
  TIME_STRINGS = /now|ahora|min|hr|in|en|hour|hora/.freeze

  def self.origin_time(human_input, origin_time_zone)
    if human_input =~ TIME_STRINGS # now, 10 minutes or 2 hours
      secs_to_add = 0
      if match = human_input.match(/([0-9\-.,]+)/)
        secs_to_add = match[1].sub(/,/, '.').to_f * 60
        secs_to_add *= 60 if human_input =~ /hour|hora|hr/
      elsif human_input.match(/(an|one|una).*(hr|hour|hora)/)
        secs_to_add = 3600
      end
      origin_time = Time.use_zone(origin_time_zone) do Time.current + secs_to_add; end
    else
      origin_time = Time.use_zone(origin_time_zone) do Time.zone.parse(human_input); end
    end
    origin_time.change(sec:0, usec:0) if origin_time
  end
end