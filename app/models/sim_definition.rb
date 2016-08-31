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
    @ride_zone_name = @data['ride_zone_name']
    @drivers = @data['drivers'] || []
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

  private
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