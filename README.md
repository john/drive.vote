# README

Drive the Vote helps people arrange free rides to the polls on election day.

## Running the code
1. Install postgresql.
1. Install Redis
1. Run `rake pg:first_run` on the first run, and `rake pg:start` for subsequent runs to start the DB
1. Run `bundle exec rails s` to start the server

## Using the app.
The app is not very functional without a logged in session. To login, visit `localhost:3000/users/sign_in`.
Refer to `db/seed.rb` for login info in dev.

The site's navigation structure is incomplete currently so not all components (eg, admin/dispatch/driver) are
always easily findable. If developing on a component, visit the specific url found in `rake routes`. The following
URLs are useful:

  * http://localhost:3000/admin -- Admin console
  * http://localhost:3000/dispatch/[id] -- Dispatch app. Id should be a number corresponding to the ride zone id. Try 1.

TODO(awong): Add a sign-in button and improve nav structure for at least development.


## Running tests

`rake spec` executes all tests in the spec directory.


## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Follow rails [core team coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#write-your-code)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

This software is released under the MIT License. See the LICENSE.md file for more information.
