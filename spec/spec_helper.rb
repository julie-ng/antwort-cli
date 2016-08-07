ENV['RACK_ENV'] = 'test'

require 'pathname'
require 'antwort'
require 'rspec'
require 'rack/test'

Pathname.glob(Pathname(__dir__) + 'support' '**/*.rb').each { |f| require f }

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include Rack::Test::Methods

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  def fixtures_root
    File.join(File.dirname(__FILE__), "fixtures")
  end

  config.before :suite do
    ENV['AWS_ACCESS_KEY_ID']      ||= 'MY_TEST_ACCESS_KEY'
    ENV['AWS_SECRET_ACCESS_KEY']  ||= 'MY_TEST_SECRET_ACCESS_KEY'
    ENV['AWS_BUCKET']             ||= 'MY_TEST_BUCKET'
    ENV['SEND_FROM']              ||= 'TEST_ENV_SEND_FROM'
    ENV['SEND_TO']                ||= 'TEST_ENV_SEND_TO'
    ENV['ASSET_SERVER']           ||= ''

    Dir.chdir(fixtures_root)
  end

  config.before :each do
    allow($stdout).to receive(:write)
  end
end

Mail.defaults do
  delivery_method :test
end
