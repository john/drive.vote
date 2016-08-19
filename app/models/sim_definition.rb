class SimDefinition
  attr_reader :slug, :name, :user_identifier, :ride_zone_name, :drivers, :voters, :run_time

  def initialize(filename)
    @data = YAML.load_file(filename)
    @slug = @data['slug']
    @name = @data['name']
    @drivers = @data['drivers']
    @ride_zone_name = @data['ride_zone_name']
    @voters = @data['voters']
    @user_identifier = @data['user_identifier']
    @run_time = calc_run_time
  end

  private
  def calc_run_time
    max_time = 0
    @drivers.each do |driver|
      driver['events'].each do |event|
        at = event['at']
        max_time = at if at > max_time
      end
    end
    @voters.each do |voter|
      voter['events'].each do |event|
        at = event['at']
        max_time = at if at > max_time
      end
    end
    max_time
  end
end