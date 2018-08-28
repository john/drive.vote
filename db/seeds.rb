# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create!(
  name: 'Generic Admin',
  available: false,
  email: 'seeds@drive.vote',
  password: '1234abcd',
  phone_number_normalized: '+15550222222',
  locale: 'en',
)


john = User.create!(
  name: 'John McGrath',
  available: false,
  email: 'john@fnnny.com',
  password: '1234abcd',
  phone_number: '5552222222',
  phone_number_normalized: '+15554222223',
  locale: 'en',
  address1: '1100 Nugget Ave',
  city: 'San Francisco',
  state: 'CA'
)

# adam = User.create!(
#   name: 'Adam McAmis',
#   available: false,
#   email: 'mcamis@gmail.com',
#   password: '1234abcd',
#   phone_number_normalized: '+15550222222',
#   locale: 'en',
# )

# albert = User.create!(
#   name: 'Albert Wong',
#   available: false,
#   email: 'awong.public@gmail.com',
#   password: '1234abcd',
#   phone_number_normalized: '+15551222222',
#   locale: 'en',
# )
#
# erin = User.create!(
#   name: 'Erin Germ',
#   available: false,
#   email: 'erin@eringerm.com',
#   password: '1234abcd',
#   phone_number_normalized: '+15552222222',
#   locale: 'en',
# )
#
# gerald = User.create!(
#   name: 'Gerald Huff',
#   available: false,
#   email: 'gerald.huff@gmail.com',
#   password: '1234abcd',
#   phone_number_normalized: '+15553222222',
#   locale: 'en',
#   city: 'Berkeley',
#   state: 'CA'
# )

roles = Role.create([
  {name: 'admin'},
  {name: 'dispatcher'},
  {name: 'driver'},
  {name: 'unassigned_driver'},
  {name: 'voter'},
])

admin.add_role(:admin)
# adam.add_role(:admin)
# albert.add_role(:admin)
# erin.add_role(:admin)
# gerald.add_role(:admin)
john.add_role(:admin)

# if  Rails.env == "development"
zones = RideZone.create!([
  {
    name: 'Berkeley, CA',
    phone_number: '+15102579445',
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
    phone_number: '+14152002626',
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

drivers = User.create!([
  {
    name: 'Deborah Driver',
    available: false,
    email: 'deborah@fnnny.com',
    password: '1234abcd',
    phone_number: '2123328709',
    phone_number_normalized: '+15555222222',
    image_url: '',
    locale: 'en',
    zip: '84122'
  }, {
    name: 'Doug Driver',
    available: false,
    email: 'doug@fnnny.com',
    password: '1234abcd',
    phone_number: '2133328709',
    phone_number_normalized: '+15556222222',
    image_url: '',
    locale: 'en',
    zip: '84122'
  }
])

rz = RideZone.find_by_slug('orlando')
drivers[0].add_role(:unassigned_driver, rz)
drivers[1].add_role(:unassigned_driver, rz)
