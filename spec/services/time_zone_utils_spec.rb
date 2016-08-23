require 'rails_helper'

RSpec.describe TimeZoneUtils do
  let!(:tz_offset) { 1.minute }
  let!(:utc_offset) { Time.now.utc_offset + tz_offset }

  around :each do |example|
    Timecop.freeze do
      example.run
    end
  end

  %w(now ahora).each do |now_str|
    it "handles now string #{now_str}" do
      fake_server, origin = TimeZoneUtils.fake_server_time_and_origin_time(now_str, utc_offset)
      expect(fake_server).to eq(tz_offset.from_now.change(sec:0, usec: 0))
      expect(origin).to eq(Time.now.change(sec:0, usec: 0))
    end
  end

  ['10 min', 'in 10 mins', 'in 10', 'en 10 minutos'].each do |future_str|
    it "handles minutes from now string '#{future_str}'" do
      fake_server, origin = TimeZoneUtils.fake_server_time_and_origin_time(future_str, utc_offset)
      expect(fake_server).to eq((10.minutes + tz_offset).from_now.change(sec:0, usec: 0))
      expect(origin).to eq(10.minutes.from_now.change(sec:0, usec: 0))
    end
  end

  ['an hour', 'in 1 hr', '1 hour', 'en 1 hora', 'en una hora'].each do |future_str|
    it "handles hours string '#{future_str}'" do
      fake_server, origin = TimeZoneUtils.fake_server_time_and_origin_time(future_str, utc_offset)
      expect(fake_server).to eq((1.hour + tz_offset).from_now.change(sec:0, usec: 0))
      expect(origin).to eq(1.hour.from_now.change(sec:0, usec: 0))
    end
  end

  ['in 0.5 hrs', '.5 hours', 'en 0,5 horas'].each do |future_str|
    it "handles fractional hours string '#{future_str}'" do
      fake_server, origin = TimeZoneUtils.fake_server_time_and_origin_time(future_str, utc_offset)
      expect(fake_server).to eq((30.minutes + tz_offset).from_now.change(sec:0, usec: 0))
      expect(origin).to eq(30.minutes.from_now.change(sec:0, usec: 0))
    end
  end
end