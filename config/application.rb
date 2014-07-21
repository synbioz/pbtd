require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pbtd
  class Application < Rails::Application
    config.time_zone = 'Paris'
    config.i18n.default_locale = :fr
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #
    # Use rspec and fabrication gem to test and fixtures
    config.generators do |g|
      g.test_framework      :rspec, fixture: true
      g.fixture_replacement :fabrication
    end

    # autoload libs
    config.autoload_paths << Rails.root.join('lib', 'capistrano_reader')
    config.autoload_paths << Rails.root.join('lib', 'git_repository')
  end
end
