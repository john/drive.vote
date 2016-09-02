class SimDefinition
  attr_reader :slug, :name, :user_identifier, :ride_zone_name, :drivers, :voters, :rides, :run_time, :file_name

  def load_file(filename)
    @file_name = filename
    load(File.read(filename))
    self
  end

  def reload
    load(File.read(@file_name)) if @file_name
  end

  def load(content)
    @data = YAML.load(content)
    @slug = @data['slug']
    @name = @data['name']
    @ride_zone_data = @data['ride_zone']
    @ride_zone_name = @ride_zone_data['name']
    create_drivers
    @voters = @data['voters'] || []
    @rides = @data['rides'] || []
    @user_identifier = @data['user_identifier']
    @run_time = calc_run_time
    self
  end

  # returns two copies of the at time for saving into last_at
  def self.calc_start(last_at, at)
    if last_at && at.to_s[0] == '+'
      at = at.to_i + last_at
    end
    return at.to_i, at.to_i
  end

  def create_ride_zone
    ride_zone = RideZone.find_by_name(@ride_zone_name)
    if ride_zone
      ride_zone.update_attributes!(@ride_zone_data)
    else
      ride_zone = RideZone.create!(@ride_zone_data)
    end
    ride_zone
  end

  private
  def create_drivers
    @drivers = []
    (@data['drivers'] || []).each_with_index do |info, i|
      count = info['count'] || 1
      time_jitter = info['time_jitter'] || 0
      loc_jitter = info['loc_jitter'] || 0
      raise "bad driver #{i} info" unless info['events'][0]['type'] == 'move'
      count.times do
        driver = info.deep_dup
        first_move = driver['events'][0]
        first_move['at'] = first_move['at'] + ((rand(100).to_f/100.0) * time_jitter)
        first_move['lat'] = first_move['lat'] + ((rand(100).to_f/100.0) * loc_jitter)
        first_move['lng'] = first_move['lng'] + ((rand(100).to_f/100.0) * loc_jitter)
        @drivers << driver
      end
    end
  end

  def calc_run_time
    max_time = 0
    @drivers.each do |driver|
      last_at = nil
      driver['events'].each do |event|
        start, last_at = SimDefinition.calc_start(last_at, event['at'])
        if event['repeat_count'] && event['repeat_time']
          start += event['repeat_count'] * event['repeat_time']
        end
        max_time = start if start > max_time
      end
    end
    @voters.each do |voter|
      last_at = nil
      voter['events'].each do |event|
        start, last_at = SimDefinition.calc_start(last_at, event['at'])
        max_time = start if start > max_time
      end
    end
    max_time
  end
end