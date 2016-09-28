require 'sim_definition'

class Simulation < ActiveRecord::Base
  RANDOM_NAMES = File.read(File.join(%W[#{Rails.root} data random_names.txt])).split("\n")
  SIM_FILES = Dir.glob(File.join(%W[#{Rails.root} data simulations *.yaml]))
  SIM_DEFS = SIM_FILES.map {|f| SimDefinition.new.load_file(f)}

  SLEEP_INTERVAL = 1
  DB_CHECK_INTERVAL = 2
  DB_CHECK_COUNTER = DB_CHECK_INTERVAL / SLEEP_INTERVAL
  WAITING_ASSIGNMENT_INTERVAL = 1.minute
  EVENT_RUN_POOL = ENV['SIM_EVENT_POOL'].try(:to_i) || 15 # simultaneous events to run

  USERNAME_BODY = '<USERNAME>'.freeze

  enum status: { preparing: 0, running: 1, stopped: 2, completed: 3, failed: 4}

  attr_reader :events
  attr_accessor :definition

  def self.find_named_sim_def(tag)
    SIM_DEFS.detect {|sim| sim.slug == tag || sim.name == tag}
  end

  def self.create_named_sim(slug)
    sim = find_named_sim_def(slug)
    return "Sim definition #{slug} not found" unless sim
    self.create_from_def(sim)
  end

  def self.create_from_def(simdef)
    rz = simdef.create_ride_zone rescue nil
    return 'Could not create or update ride zone' unless rz
    s = Simulation.create!(name: simdef.name)
    s.definition = simdef
    s
  end

  def self.can_start_new?
    Simulation.where.not(status: [:failed, :completed]).count == 0
  end

  def self.clear_all_data
    # do not interrupt if anything is running
    if self.can_start_new?
      SIM_DEFS.each { |sim| Simulation.clean_up(sim) }
      Simulation.delete_all
    end
  end

  def run_time
    sim_def.try(:run_time)
  end

  def active?
    self.status == 'running' || self.status == 'preparing'
  end

  def play
    logger.info "Starting to play #{name} #{id}"
    prepare_and_run
  end

  def stop
    self.status = :stopped
    save
  end

  def sim_def
    @definition ||= Simulation.find_named_sim_def(self.name)
  end

  private

  def prepare_and_run
    self.status = :preparing
    save
    Thread.new do
      begin
        ActiveRecord::Base.connection_pool.with_connection do
          sim_def.reload
          Simulation.clean_up(sim_def)
          setup_data
        end
        run_timeline
      rescue => e
        logger.warn "Sim prep failed with #{e.message} #{e.backtrace}"
        ActiveRecord::Base.connection_pool.with_connection do
          update_attribute(:status, :failed)
        end
      end
    end
  end

  def setup_data
    @ride_zone = RideZone.find_by_name(sim_def.ride_zone_name)
    @events = []
    create_drivers
    create_voters
    create_rides
  end

  def create_drivers
    User.sim_mode = true
    begin
      sim_def.drivers.each_with_index do |driver, i|
        broadcast_event("Creating #{sim_def.drivers.length - i} more drivers") if (i % 10) == 0
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
    ensure
      User.sim_mode = false
    end
  end

  def create_driver(i)
    User.create!(name: next_random_name, user_type: :driver, ride_zone: @ride_zone, available: true,
                    email: "simdriver#{i}@example.com", password: '123456789', city: @ride_zone.city,
                    state: @ride_zone.state, zip: @ride_zone.zip,
                    phone_number: '510-612-%03d7' % i )
  end

  # voters are actually created by inbound sms's. we just assign their events
  # to a unique phone number
  def create_voters
    broadcast_event("Creating #{sim_def.voters.length} voters")
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
    broadcast_event("Creating #{sim_def.rides.length} rides")
    sim_def.rides.each_with_index do |ride, i|
      voter = User.create!(name: next_random_name, user_type: :voter, ride_zone: @ride_zone,
                   email: "simvoter#{i}@example.com", password: '123456789', city: @ride_zone.city,
                   state: @ride_zone.state, zip: @ride_zone.zip,
                   phone_number: '510-617-%03d7' % i )
      # simulate a conversation created by the staff person creating this ride
      convo = Conversation.create(user: voter, from_phone: @ride_zone.phone_number, to_phone: voter.phone_number,
                                  ride_zone: @ride_zone)
      Message.create(conversation: convo, ride_zone: @ride_zone, from: @ride_zone.phone_number, to: voter.phone_number,
                            body: 'Thanks for scheduling a ride')
      ride_attrs = ride.dup
      offset = ride_attrs.delete('pickup_offset')
      ride_attrs['pickup_at'] = TimeZoneUtils.origin_time(offset, @ride_zone.time_zone)
      Ride.create!(ride_attrs.merge(voter: voter, ride_zone: @ride_zone, name: voter.name, status: :scheduled, conversation: convo))
    end
  end

  def run_timeline
    update_attribute(:status, :running)
    ActionCable.server.broadcast 'simulation', {type: 'status', status: 'running', id: self.id}
    timeline = @events.sort_by {|ev| ev[0]}
    final_status = :completed
    Thread.new do
      begin
        last_assignment_check = start = Time.now
        logger.info "Starting simulator thread at #{start}"
        counter = 0
        stopped = false
        while timeline.length > 0 && !stopped
            runtime = Time.now - start
            events_to_run = []
            next_time, next_event = timeline.first
            while next_time && runtime >= next_time
              events_to_run << next_event
              timeline.shift
              next_time, next_event = timeline.first
            end
            if events_to_run.length > 0
              execute_events(runtime, events_to_run)
            else
              sleep SLEEP_INTERVAL
              if counter % DB_CHECK_COUNTER == 0
                stopped = Simulation.is_stopped?(self.id)
              end
              counter += 1
              if Time.now - last_assignment_check > WAITING_ASSIGNMENT_INTERVAL
                ActiveRecord::Base.connection_pool.with_connection do
                  Ride.where(ride_zone: @ride_zone, status: :scheduled).where('pickup_at < ?', 5.minutes.from_now).each do |ride|
                    ride.update_attribute(:status, :waiting_assignment)
                  end
                end
                last_assignment_check = Time.now
              end
            end
        end
      rescue =>e
        final_status = :failed
        logger.warn "Simulator crash #{e.message} #{e.backtrace}"
      end
      update_attribute(:status, final_status)
      logger.info "Ending simulator thread at #{Time.now}"
      ActionCable.server.broadcast 'simulation', {type: 'status', status: 'complete', id: self.id}
    end
  end

  # executes a potentially large set of events in slices using
  # parallel threads
  def execute_events(runtime, events_to_run)
    broadcast_event("#{(runtime/60).floor}:%02d - #{events_to_run.length} event(s)" % (runtime % 60))
    events_to_run.each_slice(EVENT_RUN_POOL) do |events|
      break if Simulation.is_stopped?(self.id)
      events.map do |event|
        Thread.new do
          begin
            ActiveRecord::Base.connection_pool.with_connection do
              execute_event(event)
            end
          rescue => e
            logger.warn "Event execution crash #{e.message} #{e.backtrace}"
          end
        end
      end.map(&:join)
    end
  end

  def self.is_stopped?(sim_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Simulation.find(sim_id).status == 'stopped'
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
      voter_time = TimeZoneUtils.origin_time(event['time_offset'], @ride_zone.time_zone)
      event['body'] = voter_time.strftime('%l:%M %P')
    end
    params = ActionController::Parameters.new({'To' => @ride_zone.phone_number, 'From' => event[:user_phone], 'Body' => event['body']})
    TwilioService.new.process_inbound_sms(params)
  end

  def broadcast_event(name)
    ActionCable.server.broadcast 'simulation', {type: 'event', id: self.id, name: name}
  end

  # clean up all records associated with a sim definition, starting
  # with the unique user identifier
  def self.clean_up(sim_def)
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
end