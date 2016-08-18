# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

john = User.create!(
  name: 'John McGrath',
  available: false,
  email: 'john@fnnny.com',
  password: 'H3yS@ilor',
  phone_number: '2073328709',
  # phone_number_normalized: '+12073328709',
  image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
  locale: 'en',
  address1: '330 Cabrillo St.',
  city: 'Orlando',
  state: 'FL'
)

roles = Role.create( [{name: 'admin'}, {name: 'dispatcher'}, {name: 'driver'}, {name: 'rider'}] )
john.add_role(:admin)

if  Rails.env == "development"

  ride_zones = RideZone.create!([
    {
      slug: 'toledo_d_4',
      name: 'Toldedo, District 4',
      phone_number: '+14193860121',
      zip: '43601'
    }
  ])

  ride_zones = RideZone.create!([
    {
      slug: 'tampa_fl',
      name: 'Tampa, FL',
      phone_number: '+19993860121',
      zip: '33601'
    }
  ])

  conversation = Conversation.create!(
    ride_zone_id: ride_zones.first.id,
    user_id: john.id,
    from_phone: '+12073328709',
    to_phone: '+14193860121',
    status: 0
  )

  messages = Message.create!([
    {
      ride_zone_id: ride_zones.first.id,
      conversation_id: conversation.id,
      to: '+14193860121',
      from: '+12073328709',
      body: 'Hey can I get a ride at the corner of 2nd and Main?',
      sms_message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      sms_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      sms_status: 'received',
      message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
      account_sid: 'AC475463f2a2fc6828b1d32769febd680d'
    },
    {
      ride_zone_id: ride_zones.first.id,
      conversation_id: conversation.id,
      to: '+14193860121',
      from: '+12073328709',
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
    available: false,
    email: 'john@fryolator.com',
    password: 'phubharblarg',
    phone_number: '2123328709',
    phone_number_normalized: '+12073328709',
    image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
    locale: 'en',
    zip: '43606'
  )
  test_john.add_role(:unassigned_driver)

end
