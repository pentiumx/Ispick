# SimpleCov configuration
require 'simplecov'
SimpleCov.start do
  # Ignore these paths
  add_filter '/vendor/bundle/'
  add_filter '/script/pixiv'
  add_filter '/script/scrape/_legacy'
  add_filter '/script/deliver'
  add_filter '/lib/tasks'
  add_filter 'config'
  add_filter '/spec/factories'
  add_filter '/spec/support'
  add_filter '/app/admin'
  add_filter '/spec/teaspoon_env.rb'
  #add_filter 'config/initializers/reload_lib'
  #add_filter 'config/initializers/teaspoon'

  add_group 'Models', 'app/models'
end
SimpleCov.command_name "rspec"
SimpleCov.command_name "RSpec"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara'
require 'capybara/rspec'
require 'database_cleaner'
Capybara.javascript_driver = :webkit
#Capybara.current_session.driver.header('Accept-Language', 'ja')

# Initialize webmock gem
require 'webmock/rspec'
WebMock.allow_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.color = true

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # FactoryGirl configuration
  config.include FactoryGirl::Syntax::Methods
  config.before do
    FactoryGirl.reload
  end

  # Devise configuration
  # Don't set 'type: controller' to pass view specs
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view

  config.include ControllerMacros, :type => :controller
  #config.include WaitForAjax, type: :feature
  config.include WaitForAjax


  # Capybara
  config.include Capybara::DSL

  # Integration Test helper
  config.include OmniauthMacros

  # Switching callbacks
  config.before(:all, callbacks: false) do
    ActiveRecord::Base.skip_callbacks = false
  end
  config.after(:all, callbacks: true) do
    ActiveRecord::Base.skip_callbacks = true
  end

  # Skip callbacks as default
  ActiveRecord::Base.skip_callbacks = true
end
