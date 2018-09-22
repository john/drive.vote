# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

roles = Role.create([
  {name: 'admin'},
  {name: 'dispatcher'},
  {name: 'driver'},
  {name: 'unassigned_driver'},
  {name: 'voter'},
])

zones = RideZone.create!([
  {
    name: 'Berkeley, CA',
    phone_number: '+15102579445',
    email: 'berkeley@fnnny.com',
    slug: 'berkeley',
    city: 'Berkeley',
    state: 'CA',
    zip: '89169',
    country: 'us',
    latitude: 37.8760097,
    longitude: -122.3157274,
    time_zone: 'America/Los_Angeles',
  },
  {
    name: 'San Francisco, CA',
    phone_number: '+14158519528',
    email: 'sf@fnnny.com',
    slug: 'san_francisco',
    city: 'San Francisco',
    state: 'CA',
    zip: '94118',
    country: 'us',
    latitude: 37.7756912,
    longitude: -122.464523,
    time_zone: 'America/Los_Angeles',
  },
  {
    name: 'Orlando, FL',
    phone_number: '+14073095953',
    email: 'orlando@fnnny.com',
    slug: 'orlando',
    city: 'Orlando',
    state: 'FL',
    zip: '32839',
    country: 'us',
    latitude: '28.4813986',
    longitude: '-81.5091796',
    time_zone: 'America/New_York'
  }
])

sf = RideZone.find_by_slug('san_francisco')
orlando = RideZone.find_by_slug('orlando')

generic_admin = User.create!(
  name: 'Generic Admin',
  available: false,
  email: 'seeds@drive.vote',
  password: '1234abcd',
  phone_number: '5552222222',
  phone_number_normalized: '+15550222222',
  locale: 'en',
)

john = User.create!(
  name: 'John McGrath',
  available: false,
  email: 'john@fnnny.com',
  password: '1234abcd',
  phone_number: '5552222223',
  phone_number_normalized: '+15554222223',
  locale: 'en',
  address1: '1100 Nugget Ave',
  city: 'San Francisco',
  state: 'CA'
)

sf_admin =  User.create!(
  name: 'SF Zone Admin',
  available: false,
  email: 'sfadmin@fnnny.com',
  password: '1234abcd',
  phone_number: '5552222224',
  phone_number_normalized: '+15554222224',
  locale: 'en',
  address1: '1100 Nugget Ave',
  city: 'San Francisco',
  state: 'CA'
)

generic_admin.add_role(:admin)
john.add_role(:admin)
sf_admin.add_role(:admin, sf)

drivers = User.create!([
  {
    name: 'Deborah Driver',
    available: false,
    email: 'deborah@fnnny.com',
    password: '1234abcd',
    phone_number: '2073328709',
    phone_number_normalized: '+12073328709',
    image_url: '',
    locale: 'en',
    zip: '94121'
  }, {
    name: 'Doug Driver',
    available: false,
    email: 'doug@fnnny.com',
    password: '1234abcd',
    phone_number: '5552222226',
    phone_number_normalized: '+15556222226',
    image_url: '',
    locale: 'en',
    zip: '84122'
  }, {
    name: 'Danny Driver',
    available: false,
    email: 'danny@fnnny.com',
    password: '1234abcd',
    phone_number: '5552222227',
    phone_number_normalized: '+15556222227',
    image_url: '',
    locale: 'en',
    zip: '84122'
  }, {
    name: 'Donnie Driver',
    available: false,
    email: 'donnie@fnnny.com',
    password: '1234abcd',
    phone_number: '5552222228',
    phone_number_normalized: '+15556222228',
    image_url: '',
    locale: 'en',
    zip: '84122'
  }
])

dispatchers = User.create!([
  name: 'SF Dispatcher',
  available: false,
  email: 'sfdispatch@fnnny.com',
  password: '1234abcd',
  phone_number: '5552222229',
  phone_number_normalized: '+15554222229',
  locale: 'en',
  address1: '1100 Nugget Ave',
  city: 'San Francisco',
  state: 'CA'
])

drivers[0].add_role(:unassigned_driver, sf)
drivers[1].add_role(:driver, sf)
drivers[2].add_role(:driver, sf)
drivers[3].add_role(:unassigned_driver, orlando)

dispatchers[0].add_role(:dispatcher, sf)
