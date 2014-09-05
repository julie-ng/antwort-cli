require 'pathname'
require 'antwort'
require 'rspec/its'

Pathname.glob(Pathname(__dir__) + 'support' '**/*.rb').each { |f| require f }

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end
