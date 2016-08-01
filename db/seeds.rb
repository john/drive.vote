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
  provider: 'facebook',
  uid: '10155022838063242',
  address1: '330 Cabrillo St.',
  city: 'San Francisco',
  state: 'CS'
  )
  
test_john = User.create!(
  name: 'John Test',
  email: 'john@fryolator.com',
  password: 'phubharblarg',
  phone_number: '2073328709',
  phone_number_normalized: '+12073328709',
  image_url: 'http://graph.facebook.com/v2.6/10155022838063242/picture',
  locale: 'en',
  provider: 'facebook',
  uid: '99955022838063242',
  address1: '330 Cabrillo St.',
  city: 'San Francisco',
  state: 'CS'
  )

roles = Role.create(
  [{name: 'admin'}, {name: 'dispatcher'}, {name: 'driver'}, {name: 'rider'}]
)

roles.each do |role|
  john.grant( role.name.to_sym )
  test_john.grant( role.name.to_sym )
end

pres = Election.create(
  owner_id: User.first.id,
  slug: 'president_2016',
  name: '2016 Presidential Election',
  date: '2016-11-08 08:27:00'
)

hillary = Campaign.create(
  election_id: pres.id,
  owner_id: User.first.id,
  slug: 'hillary2016',
  name: 'Hillary for America 2016',
  start_date: '2016-08-01 08:27:00',
  party_affiliation: 0
)