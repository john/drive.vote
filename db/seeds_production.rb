# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# heroku run bash --app drivethevote
# wget https://transfer.sh/eitfs/seeds.rb

# heroku run bundle exec rake db⣷drop --app drivethevote DISABLE_DATABASE_ENVIRONMENT_CHECK=1
# heroku run bundle exec rake db:setup --app drivethevote

# heroku run bundle exec rake db:create --app drivethevote
# heroku run bundle exec rake db:migrate --app drivethevote
# heroku run bundle exec rake db:seed --app drivethevote

roles = Role.create([
  {name: 'admin'},
  {name: 'dispatcher'},
  {name: 'driver'},
  {name: 'unassigned_driver'},
  {name: 'voter'},
])

zones = RideZone.create!([
  {
    name: 'Texas 14th Congressional District',
    phone_number: '+17137661273',
    email: 'hello-tx@drive.vote',
    slug: 'tx-14',
    city: 'Houston',
    state: 'TX',
    zip: '77584',
    country: 'us',
    time_zone: 'America/Chicago',
    latitude: 29.518596,
    longitude: -95.291371,
    max_pickup_radius: 20.0,
  },
  {
    name: 'Wisconsin 1st Congressional District',
    phone_number: '+12626724876',
    email: 'hello-wi@drive.vote',
    slug: 'wi-1',
    city: 'Racine',
    state: 'WI',
    zip: '53404',
    country: 'us',
    time_zone: 'America/Chicago',
    latitude: 42.796409,
    longitude: -88.06696,
    max_pickup_radius: 20.0,
  },
  {
    name: 'California 25th Congressional District',
    phone_number: '+12133548858',
    email: 'hello-ca@drive.vote',
    slug: 'ca-25',
    city: 'Stevenson Ranch',
    state: 'CA',
    zip: '91381',
    country: 'us',
    time_zone: 'America/Los_Angeles',
    latitude: 34.214744,
    longitude: -118.60534,
    max_pickup_radius: 20.0,
  }
])

john = User.create!(
  name: 'John McGrath',
  available: false,
  email: 'john@fnnny.com',
  password: '1234abcd',
  phone_number: '2073328709',
  phone_number_normalized: '+12073328709',
  locale: 'en',
  address1: '',
  city: 'San Francisco',
  state: 'CA'
)

jill =  User.create!(
  name: 'Jill Huchital',
  available: false,
  email: 'jill@ragtag.org',
  password: '1234abcd',
  phone_number: '4087686946',
  phone_number_normalized: '+14087686946',
  locale: 'en',
  address1: '',
  city: 'San Francisco',
  state: 'CA'
)

brady =  User.create!(
  name: 'Brady Kriss',
  available: false,
  email: 'brady@ragtag.org',
  password: '1234abcd',
  phone_number: '6174476506',
  phone_number_normalized: '+16174476506',
  locale: 'en',
  address1: '',
  city: 'San Francisco',
  state: 'CA'
)

dan =  User.create!(
  name: 'Dan Ryan',
  available: false,
  email: 'dan@ragtag.org',
  password: '1234abcd',
  phone_number: '4238477626',
  phone_number_normalized: '+14238477626',
  locale: 'en',
  address1: '',
  city: 'Chattanooga',
  state: 'TN'
)

seth =  User.create!(
  name: 'Seth Marbin',
  available: false,
  email: 'smarbin@gmail.com',
  password: '1234abcd',
  phone_number: '4153170671',
  phone_number_normalized: '+14153170671',
  locale: 'en',
  address1: '',
  city: 'San Francisco',
  state: 'CA'
)

john.add_role(:admin)
jill.add_role(:admin)
brady.add_role(:admin)
dan.add_role(:admin)
seth.add_role(:admin)

# creates:
# https://www.drive.vote/ride/tx-14
# https://www.drive.vote/ride/wi-1
# https://www.drive.vote/ride/ca-25




# creates:
# https://www.drive.vote/ride/tx-14
# https://www.drive.vote/ride/wi-1
# https://www.drive.vote/ride/ca-25



# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
# #
# # Examples:
# #
# #   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
# #   Character.create(name: 'Luke', movie: movies.first)
#
# roles = Role.create([
#   {name: 'admin'},
#   {name: 'dispatcher'},
#   {name: 'driver'},
#   {name: 'unassigned_driver'},
#   {name: 'voter'},
# ])
#
# zones = RideZone.create!([
#   {
#     name: 'Berkeley, CA',
#     phone_number: '+15102579445',
#     email: 'berkeley@fnnny.com',
#     slug: 'berkeley',
#     city: 'Berkeley',
#     state: 'CA',
#     zip: '89169',
#     country: 'us',
#     time_zone: 'America/Los_Angeles',
#     latitude: 37.8760097,
#     longitude: -122.3157274,
#     max_pickup_radius: 20.0,
#   },
#   {
#     name: 'San Francisco, CA',
#     phone_number: '+14158519528',
#     email: 'sf@fnnny.com',
#     slug: 'san_francisco',
#     city: 'San Francisco',
#     state: 'CA',
#     zip: '94118',
#     country: 'us',
#     latitude: 37.7756912,
#     longitude: -122.464523,
#     time_zone: 'America/Los_Angeles',
#   },
#   {
#     name: 'Orlando, FL',
#     phone_number: '+14073095953',
#     email: 'orlando@fnnny.com',
#     slug: 'orlando',
#     city: 'Orlando',
#     state: 'FL',
#     zip: '32839',
#     country: 'us',
#     latitude: '28.4813986',
#     longitude: '-81.5091796',
#     time_zone: 'America/New_York'
#   }
# ])
#
# sf = RideZone.find_by_slug('san_francisco')
# orlando = RideZone.find_by_slug('orlando')
#
# generic_admin = User.create!(
#   name: 'Generic Admin',
#   available: false,
#   email: 'seeds@drive.vote',
#   password: '1234abcd',
#   phone_number: '5552222222',
#   phone_number_normalized: '+15550222222',
#   locale: 'en',
# )
#
# john = User.create!(
#   name: 'John McGrath',
#   available: false,
#   email: 'john@fnnny.com',
#   password: '1234abcd',
#   phone_number: '5552222223',
#   phone_number_normalized: '+15554222223',
#   locale: 'en',
#   address1: '1100 Nugget Ave',
#   city: 'San Francisco',
#   state: 'CA'
# )
#
# sf_admin =  User.create!(
#   name: 'SF Zone Admin',
#   available: false,
#   email: 'sfadmin@fnnny.com',
#   password: '1234abcd',
#   phone_number: '5552222224',
#   phone_number_normalized: '+15554222224',
#   locale: 'en',
#   address1: '1100 Nugget Ave',
#   city: 'San Francisco',
#   state: 'CA'
# )
#
# generic_admin.add_role(:admin)
# john.add_role(:admin)
# sf_admin.add_role(:admin, sf)
#
# drivers = User.create!([
#   {
#     name: 'Deborah Driver',
#     available: false,
#     email: 'deborah@fnnny.com',
#     password: '1234abcd',
#     phone_number: '2073328709',
#     phone_number_normalized: '+12073328709',
#     image_url: '',
#     locale: 'en',
#     zip: '94121'
#   }, {
#     name: 'Doug Driver',
#     available: false,
#     email: 'doug@fnnny.com',
#     password: '1234abcd',
#     phone_number: '5552222226',
#     phone_number_normalized: '+15556222226',
#     image_url: '',
#     locale: 'en',
#     zip: '84122'
#   }, {
#     name: 'Danny Driver',
#     available: false,
#     email: 'danny@fnnny.com',
#     password: '1234abcd',
#     phone_number: '5552222227',
#     phone_number_normalized: '+15556222227',
#     image_url: '',
#     locale: 'en',
#     zip: '84122'
#   }, {
#     name: 'Donnie Driver',
#     available: false,
#     email: 'donnie@fnnny.com',
#     password: '1234abcd',
#     phone_number: '5552222228',
#     phone_number_normalized: '+15556222228',
#     image_url: '',
#     locale: 'en',
#     zip: '84122'
#   }
# ])
#
# dispatchers = User.create!([
#   name: 'SF Dispatcher',
#   available: false,
#   email: 'sfdispatch@fnnny.com',
#   password: '1234abcd',
#   phone_number: '5552222229',
#   phone_number_normalized: '+15554222229',
#   locale: 'en',
#   address1: '1100 Nugget Ave',
#   city: 'San Francisco',
#   state: 'CA'
# ])
#
# drivers[0].add_role(:unassigned_driver, sf)
# drivers[1].add_role(:driver, sf)
# drivers[2].add_role(:driver, sf)
# drivers[3].add_role(:unassigned_driver, orlando)
#
# dispatchers[0].add_role(:dispatcher, sf)

