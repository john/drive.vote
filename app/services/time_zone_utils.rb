class TimeZoneUtils
  TIME_STRINGS = /now|ahora|min|hr|in|en|hour|hora/.freeze

  def self.fake_server_time_and_origin_time(human_input, origin_utc_offset)
    server_time = Time.now.change(sec:0, usec:0)
    server_to_origin_offset = server_time.utc_offset - origin_utc_offset
    fake_server_time = nil
    if human_input =~ TIME_STRINGS # now, 10 minutes or 2 hours
      secs_to_add = 0
      if match = human_input.match(/([0-9\-.,]+)/)
        secs_to_add = match[1].sub(/,/, '.').to_f * 60
        secs_to_add *= 60 if human_input =~ /hour|hora|hr/
      elsif human_input.match(/(an|one|una).*(hr|hour|hora)/)
        secs_to_add = 3600
      end
      fake_server_time = Time.at(server_time.to_i + secs_to_add - server_to_origin_offset)
      origin_time = Time.at(server_time.to_i + secs_to_add)
    end
    unless fake_server_time
      fake_server_time = Time.parse(human_input) rescue nil
      if fake_server_time
        origin_time = Time.at(fake_server_time.to_i + server_to_origin_offset)
        if origin_time.day < fake_server_time.day
          origin_time += 1.day
        end
      end
    end
    return fake_server_time, origin_time
  end
end