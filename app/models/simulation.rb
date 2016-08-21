require 'sim_definition'

class Simulation < ActiveRecord::Base
  RANDOM_NAMES = File.read(File.join(%W[#{Rails.root} data random_names.txt])).split("\n")
  SIM_FILES = Dir.glob(File.join(%W[#{Rails.root} data simulations *.yaml]))
  SIM_DEFS = SIM_FILES.map {|f| SimDefinition.new.load_file(f)}

  SLEEP_INTERVAL = 1
  DB_CHECK_INTERVAL = 2
  DB_CHECK_COUNTER = DB_CHECK_INTERVAL / SLEEP_INTERVAL

  USERNAME_BODY = '<USERNAME>'.freeze

  enum status: { preparing: 0, running: 1, stopped: 2, completed: 3, failed: 4}

  attr_reader :events
  attr_accessor :definition

  def self.find_named_sim_def(tag)
    SIM_DEFS.detect {|sim| sim.slug == tag || sim.name == tag}
  end

  def self.create_named_sim(slug)
    sim = find_named_sim_def(slug)
    return "Sim #{slug} not found" unless sim
    self.create_from_def(sim)
  end

  def self.create_from_def(sim)
    return "Sim ride zone #{sim.ride_zone_name} not found" unless RideZone.find_by_name(sim.ride_zone_name)
    s = Simulation.create!(name: sim.name)
    s.definition = sim
    s
  end

  def self.can_start_new?
    Simulation.where.not(status: [:failed, :completed]).count == 0
  end

  def run_time
    sim_def.run_time
  end

  def active?
    self.status == 'running'
  end

  def play
    logger.info "Starting to play #{name} #{id}"
    prepare
    run_timeline
  end

  def stop
    self.status = :stopped
    save
  end

  private
  def sim_def
    @definition ||= Simulation.find_named_sim_def(self.name)
  end

  def prepare
    self.status = :preparing
    save
    SIM_DEFS.each { |sim| clean_up(sim) }
    @ride_zone = RideZone.find_by_name(sim_def.ride_zone_name)
    @events = []
    create_drivers
    create_voters
    create_rides
  end

  def create_drivers
    sim_def.drivers.each_with_index do |driver, i|
      d = create_driver(i)
      last_at = nil
      driver['events'].each do |event|
        start, last_at = SimDefinition.calc_start(last_at, event['at'])
        times = [start]
        if event['repeat_count'] && event['repeat_time']
          event['repeat_count'].times do |t|
            times << (start + (t+1)*event['repeat_time'])
          end
        end
        last_at = times.last
        times.each do |t|
          @events << [t, event.merge(user: d)]
        end
      end
    end
  end

  def create_driver(i)
    User.create!(name: next_random_name, user_type: :driver, ride_zone: @ride_zone,
                    email: "simdriver#{i}@example.com", password: '123456789', city: @ride_zone.city,
                    state: @ride_zone.state, zip: @ride_zone.zip,
                    phone_number: '510-612-%03d7' % i )
  end

  # voters are actually created by inbound sms's. we just assign their events
  # to a unique phone number
  def create_voters
    sim_def.voters.each_with_index do |voter, i|
      phone = '+1510613%03d8' % i
      last_at = nil
      voter['events'].each do |event|
        body = (event['body'] == USERNAME_BODY) ? next_random_name : event['body']
        start, last_at = SimDefinition.calc_start(last_at, event['at'])
        @events << [start, event.merge(user_phone: phone, 'body' => body).compact]
      end
    end
  end

  def create_rides
    sim_def.rides.each_with_index do |ride, i|
      voter = User.create!(name: next_random_name, user_type: :voter, ride_zone: @ride_zone,
                   email: "simvoter#{i}@example.com", password: '123456789', city: @ride_zone.city,
                   state: @ride_zone.state, zip: @ride_zone.zip,
                   phone_number: '510-617-%03d7' % i )
      offset = ride.delete('pickup_offset')
      ride['pickup_at'] = offset_time(offset)
      Ride.create!(ride.merge(voter: voter, ride_zone: @ride_zone, name: voter.name, status: :scheduled))
    end
  end

  def run_timeline
    update_attribute(:status, :running)
    timeline = @events.sort_by {|ev| ev[0]}
    final_status = :completed
    Thread.new do
      begin
        start = Time.now
        logger.info "Starting simulator thread at #{start}"
        counter = 0
        stopped = false
        while timeline.length > 0 && !stopped
          next_time, next_event = timeline.first
          ActiveRecord::Base.connection_pool.with_connection do
            Ride.where(ride_zone: @ride_zone, status: :scheduled).where('pickup_at < ?', 5.minutes.from_now).each do |ride|
              ride.update_attribute(:status, :waiting_assignment)
            end
            if Time.now - start >= next_time
              execute_event(next_event)
              timeline.shift
            else
              sleep SLEEP_INTERVAL
              if counter % DB_CHECK_COUNTER == 0
                # do not reload this object instance in memory
                stopped = Simulation.find(self.id).status == 'stopped'
              end
              counter += 1
            end
          end
        end
      rescue =>e
        final_status = :failed
        logger.warn "Whoops crash #{e.message} #{e.backtrace}"
      end
      update_attribute(:status, final_status)
      logger.info "Ending simulator thread at #{Time.now}"
    end
  end

  # execute an event by calling the method with the name of the event
  # type
  def execute_event(event)
    evtype = event['type'].to_sym
    if private_methods.include?(evtype)
      logger.info "SIMULATOR executing #{event}"
      send(evtype, event)
    else
      logger.warn "Event type #{evtype} not found!"
    end
  end

  def move(event)
    event[:user].update_attributes(latitude: event['lat'], longitude: event['lng'])
  end

  def move_by(event)
    event[:user].reload
    lat, lng = event[:user].latitude, event[:user].longitude
    event[:user].update_attributes(latitude: lat + event['lat'], longitude: lng + event['lng'])
  end

  def accept_nearest_ride(event)
    u = event[:user].reload
    if u.active_ride
      logger.warn "SIMULATOR driver #{u.name} already has a ride"
    else
      rides = Ride.waiting_nearby(@ride_zone.id, u.latitude, u.longitude, 1, 50)
      if rides.empty?
        logger.warn "SIMULATOR driver #{u.name} no nearby rides"
      else
        rides.first.assign_driver(u)
      end
    end
  end

  def pickup_ride(event)
    u = event[:user].reload
    if u.active_ride
      u.active_ride.pickup_by(u)
    else
      logger.warn "SIMULATOR driver #{u.name} has no ride"
    end
  end

  def complete_ride(event)
    u = event[:user].reload
    if u.active_ride
      u.active_ride.complete_by(u)
    else
      logger.warn "SIMULATOR driver #{u.name} has no ride"
    end
  end

  def sms(event)
    if event['time_offset']
      event['body'] = offset_time(event['time_offset']).strftime('%l:%M %P')
    end
    params = ActionController::Parameters.new({'To' => @ride_zone.phone_number, 'From' => event[:user_phone], 'Body' => event['body']})
    TwilioService.new.process_inbound_sms(params)
  end

  # clean up all records associated with a sim definition, starting
  # with the unique user identifier
  def clean_up(sim_def)
    ride_zone = RideZone.find_by_name(sim_def.ride_zone_name)
    return unless ride_zone
    Ride.where(ride_zone: ride_zone).delete_all
    Message.where(ride_zone: ride_zone).delete_all
    user_ids = ride_zone.conversations.pluck(:user_id).uniq
    Conversation.where(ride_zone: ride_zone).delete_all
    user_ids = user_ids | User.where("name like '%#{sim_def.user_identifier}%'").pluck(:id)
    UsersRoles.where(user_id: user_ids).delete_all
    User.where(id: user_ids).delete_all
  end

  def next_random_name
    @used_names = [] if !@used_names || @used_names.length == RANDOM_NAMES.length # whoops, start over
    name = RANDOM_NAMES[rand(RANDOM_NAMES.length)]
    while @used_names.include?(name)
      name = RANDOM_NAMES[rand(RANDOM_NAMES.length)]
    end
    "#{name} #{sim_def.user_identifier}"
  end

  def move_driver(driver, lat, lng)
    driver.update_attributes(latitude: lat, longitude: lng)
  end

  def offset_time(str)
    val = str.to_s.to_i
    val *= 60 if str.to_s =~ /min/i
    Time.at(Time.now.to_i + val)
  end
end