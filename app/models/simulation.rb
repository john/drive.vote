class Simulation < ActiveRecord::Base
  RANDOM_NAMES = File.read(File.join(%W[#{Rails.root} data random_names.txt])).split("\n")
  SIM_FILES = Dir.glob(File.join(%W[#{Rails.root} data simulations *.yaml]))
  SIM_DEFS = SIM_FILES.map {|f| SimDefinition.new(f)}

  SLEEP_INTERVAL = 1
  DB_CHECK_INTERVAL = 2
  DB_CHECK_COUNTER = DB_CHECK_INTERVAL / SLEEP_INTERVAL

  USERNAME_BODY = '<USERNAME>'.freeze

  enum status: { preparing: 0, running: 1, stopped: 2, completed: 3}

  def self.find_named_sim_def(tag)
    SIM_DEFS.detect {|sim| sim.slug == tag || sim.name == tag}
  end

  def self.create_named_sim(slug)
    sim = find_named_sim_def(slug)
    return "Sim #{slug} not found" unless sim
    return "Sim ride zone #{sim.ride_zone_name} not found" unless RideZone.find_by_name(sim.ride_zone_name)
    Simulation.create!(name: sim.name)
  end

  def self.can_start_new?
    Simulation.where.not(status: :completed).count == 0
  end

  def run_time
    sim_def.run_time
  end

  def active?
    self.status == 'running'
  end

  def play
    logger.info "Starting to play #{name} #{id}"
    reset
    prepare
    run_timeline
  end

  def stop
    self.status = :stopped
    save
  end

  private
  def sim_def
    @sim_def ||= Simulation.find_named_sim_def(self.name)
  end

  def reset
    @events = []
    self.status = :preparing
    save
    SIM_DEFS.each { |sim| clean_up(sim) }
  end

  def prepare
    @ride_zone = RideZone.find_by_name(sim_def.ride_zone_name)
    create_drivers
    create_voters
  end

  def create_drivers
    sim_def.drivers.each_with_index do |driver, i|
      d = create_driver(i)
      driver['events'].each do |event|
        @events << [event['at'], event.merge(user: d)]
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
    @sim_def.voters.each_with_index do |voter, i|
      phone = '+1510613%03d8' % i
      voter['events'].each do |event|
        body = (event['body'] == USERNAME_BODY) ? next_random_name : event['body']
        @events << [event['at'], event.merge(user_phone: phone, 'body' => body).compact]
      end
    end
  end

  def run_timeline
    update_attribute(:status, :running)
    timeline = @events.sort_by {|ev| ev[0]}
    Thread.new do
      begin
        start = Time.now
        logger.info "Starting simulator thread at #{start}"
        counter = 0
        stopped = false
        while timeline.length > 0 && !stopped
          next_time, next_event = timeline.first
          ActiveRecord::Base.connection_pool.with_connection do
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
        logger.warn "Whoops crash #{e.message} #{e.backtrace}"
      end
      update_attribute(:status, :completed)
      logger.info "Ending simulator thread at #{Time.now}"
    end
  end

  # execute an event by calling the method with the name of the event
  # type
  def execute_event(event)
    evtype = event['type'].to_sym
    if private_methods.include?(evtype)
      send(evtype, event)
    else
      logger.warn "Event type #{evtype} not found!"
    end
  end

  def move(event)
    event[:user].update_attributes(latitude: event['lat'], longitude: event['lng'])
  end

  def sms(event)
    params = ActionController::Parameters.new({'To' => @ride_zone.phone_number, 'From' => event[:user_phone], 'Body' => event['body']})
    TwilioService.new.process_inbound_sms(params)
  end

  # clean up all records associated with a sim definition, starting
  # with the unique user identifier
  def clean_up(sim_def)
    user_ids = User.where("name like '%#{sim_def.user_identifier}%'").pluck(:id)
    conversation_ids = Conversation.where(user_id: user_ids).pluck(:id)
    UsersRoles.where(user_id: user_ids).delete_all
    Ride.where(voter_id: user_ids).delete_all
    Message.where(conversation_id: conversation_ids).delete_all
    Conversation.where(id: conversation_ids).delete_all
    User.where(id: user_ids).delete_all
  end

  def at seconds_offset, &blk
    (@events ||= []) << [seconds_offset, blk]
  end

  def next_random_name
    @used_names = [] if !@used_names || @used_names.length == RANDOM_NAMES.length # whoops, start over
    name = RANDOM_NAMES[rand(RANDOM_NAMES.length)]
    while @used_names.include?(name)
      name = RANDOM_NAMES[rand(RANDOM_NAMES.length)]
    end
    "#{name} #{@sim_def.user_identifier}"
  end

  def move_driver(driver, lat, lng)
    driver.update_attributes(latitude: lat, longitude: lng)
  end
end