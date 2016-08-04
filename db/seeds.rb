# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

john = User.create!(
  name: 'John McGrath',
  email: 'john@fnnny.com',
  password: 'foobarbah',
  phone_number: '2073328709',
  phone_number_normalized: '+12073328709',
  image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
  locale: 'en',
  address1: '330 Cabrillo St.',
  city: 'San Francisco',
  state: 'CA'
)

pres = Election.create(
  owner_id: john.id,
  slug: 'president_2016',
  name: '2016 Presidential Election',
  date: '2016-11-08 08:27:00'
)

hillary = Campaign.create(
  election_id: pres.id,
  owner_id: john.id,
  slug: 'hillary2016',
  name: 'Hillary for America 2016',
  start_date: '2016-08-01 08:27:00',
  party_affiliation: 0
)

roles = Role.create( [{name: 'admin'}, {name: 'dispatcher'}, {name: 'driver'}, {name: 'rider'}] )
roles.each { |role| john.grant( role.name.to_sym ) }

if  Rails.env == "development"
  
  ride_zones = RideZone.create!([
    {
      slug: 'toledo_d_4',
      name: 'Toldedo, District 4',
      phone_number: '+14193860121'
    }
  ])
  
  messages = Message.create!([
    {
      ride_zone_id: ride_zones.first.id,
      status: 0,
      to: '+14193860121', to_city: 'TOLEDO', to_state: 'OH',
      to_country: 'US', to_zip: '43607',
      from: '+12073328709',
      from_city: 'PORTLAND',
      from_state: 'ME',
      from_country: 'US',
      from_zip: '04102',
      body: 'Hey can I get a ride at the corner of 2nd and Main?',
      sms_message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      sms_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      sms_status: 'received',
      message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      account_sid: 'AC475463f2a2fc6828b1d32769febd680d'
    },
    {
      ride_zone_id: ride_zones.first.id,
      status: 2,
      to: '+14193860121', to_city: 'TOLEDO', to_state: 'OH',
      to_country: 'US', to_zip: '43607',
      from: '+12073328709',
      from_city: 'PORTLAND',
      from_state: 'ME',
      from_country: 'US',
      from_zip: '04102',
      body: 'come get me @ 123 main plz',
      sms_message_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
      sms_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
      sms_status: 'received',
      message_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
      account_sid: 'AC475463f2a2fc6828b1d32769febd680d'
    }
  ])
  
  test_john = User.create!(
    name: 'John Test',
    email: 'john@fryolator.com',
    password: 'phubharblarg',
    phone_number: '2073328709',
    phone_number_normalized: '+12073328709',
    image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
    locale: 'en',
    address1: '330 Cabrillo St.',
    city: 'San Francisco',
    state: 'CA'
  )
  roles.each { |role| test_john.grant( role.name.to_sym ) }
end
