source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "pg"
gem "slim-rails"
gem 'stylus'
gem "whenever"
gem "rugged"
gem 'sidekiq'
gem "puma"
gem "hipchat"
gem "airbrake"
gem "capistrano", "~> 3.2.0", require: false
gem "capistrano-rbenv", "~> 2.0", require: false
gem "capistrano-bundler", "~> 1.1.2", require: false
gem "capistrano-rails", "~> 1.1.1", require: false
gem "capistrano3-puma", require: false
gem "capistrano-sidekiq", require: false
gem "rack-cache", require: "rack/cache"
gem "faye"
gem "eventmachine"
gem 'pghero'

group :test do
  gem "rspec-rails"
  gem "guard-rspec"
  gem "shoulda-matchers"
  gem 'fabrication'
  gem 'faker'
  gem 'rspec-its'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "awesome_print"
  gem "pry-rails"
  gem "debugger2"
  gem "ruby-prof"
  gem 'sinatra', require: false
  gem "annotate"
end

group :doc do
  gem "yard"
  gem "rails-erd"
end
