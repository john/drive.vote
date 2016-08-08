# README

Drive the Vote helps people arrange free rides to the polls on election day.

## Running the App

### OS X

1. Use [brew](http://brew.sh) to install `rbenv`: `brew install rbenv`
2. Use `rbenv` to manage the ruby version: `rbenv install`
3. `gem install bundler`
4. `bundle install`
5. `brew install postgresql`
6. `brew services start postgresql`
7. `createuser -s postgres`
8. `bin/setup`
9. `bin/rails server`
10. visit [http://localhost:3000](http://localhost:3000) ‼️

## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Follow rails [core team coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#write-your-code)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

This software is released under the MIT License. See the LICENSE.md file for more information.
