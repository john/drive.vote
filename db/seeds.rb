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
  password: '1234abcd',
  phone_number: '2222222222',
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

  zones = RideZone.create!([
    {
      name: 'Las Vegas, NV',
      phone_number: '+17024890894',
      city: 'Las Vegas',
      state: 'NV',
      zip: '89169',
      country: 'us',
      latitude: 36.1295416,
      longitude: -115.1325897,
      slug: 'las_vegas',
      time_zone: 'America/Los_Angeles',

    },
    {
      name: 'Toledo, OH',
      phone_number: '+14193860121',
      city: 'Toledo',
      state: 'OH',
      zip: '43601',
      country: 'us',
      latitude: 41.6411077,
      longitude: -83.5436626,
      slug: 'toledo',
      time_zone: 'America/New_York',

    }
  ])

  drivers = User.create!([
    {
      name: 'Las Vegas Test Driver',
      available: false,
      email: 'lvtest@fryolator.com',
      password: '1234abcd',
      phone_number: '5123328709',
      phone_number_normalized: '+5123328709',
      image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
      locale: 'en',
      zip: '89169'
    },{
      name: 'Deborah Driver',
      available: false,
      email: 'john@fryolator.com',
      password: '1234abcd',
      phone_number: '2123328709',
      phone_number_normalized: '+12073328709',
      image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
      locale: 'en',
      zip: '43606'
    }, {
      name: 'Doug Driver',
      available: false,
      email: 'jmcgrath@fryolator.com',
      password: '1234abcd',
      phone_number: '2133328709',
      phone_number_normalized: '+12073328709',
      image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
      locale: 'en',
      zip: '43606'
    }
  ])

  drivers[0].add_role(:unassigned_driver)
  drivers[1].add_role(:unassigned_driver)
  drivers[2].add_role(:unassigned_driver)



  # ride_zones = RideZone.create!([
  #   {
  #     slug: 'toledo_d_4',
  #     name: 'Toledo, OH',
  #     phone_number: '+14193860121',
  #     zip: '43601',
  #     latitude: '41.6639',
  #     longitude: '-83.5552'
  #   },
  #   {
  #     slug: 'tampa_fl',
  #     name: 'Tampa, FL',
  #     phone_number: '+18133580421',
  #     zip: '33601',
  #     latitude: '27.9506',
  #     longitude: '-82.4572'
  #   }
  # ])

  # conversation = Conversation.create!(
  #   ride_zone_id: ride_zones.first.id,
  #   user_id: john.id,
  #   from_phone: '+12073328709',
  #   to_phone: '+14193860121',
  #   status: 0
  # )
  #
  # messages = Message.create!([
  #   {
  #     ride_zone_id: ride_zones.first.id,
  #     conversation_id: conversation.id,
  #     to: '+14193860121',
  #     from: '+12073328709',
  #     body: 'Hey can I get a ride at the corner of 2nd and Main?',
  #     sms_message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
  #     sms_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
  #     sms_status: 'received',
  #     message_sid: 'SMc55b4910a4bcb08c3f4f0d725dff0380',
  #     account_sid: 'AC475463f2a2fc6828b1d32769febd680d'
  #   },
  #   {
  #     ride_zone_id: ride_zones.first.id,
  #     conversation_id: conversation.id,
  #     to: '+14193860121',
  #     from: '+12073328709',
  #     body: 'come get me @ 123 main plz',
  #     sms_message_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
  #     sms_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
  #     sms_status: 'received',
  #     message_sid: 'SM24dff084f7383bc6ba766b9e91f166ae',
  #     account_sid: 'AC475463f2a2fc6828b1d32769febd680d'
  #   }
  # ])

end
