# frozen_string_literal: true

require File.expand_path('../lib/gripst', __dir__)
require 'pry'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random

  Kernel.srand config.seed
end
