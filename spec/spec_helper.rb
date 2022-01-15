# frozen_string_literal: true

require_relative '../config/environment'
# require 'vcr'
# require 'support/shared_examples/base_class_functionality_spec'

# VCR.configure do |config|
#   config.cassette_library_dir = 'spec/fixtures/vcr'
#   config.default_cassette_options = { match_requests_on: %i[method uri body], record: :once }
#   config.filter_sensitive_data('<ACOUSTID_CLIENT_ID>') { ENV['ACOUSTID_CLIENT_ID'] }
#   config.configure_rspec_metadata! # enables :vcr tag
#   config.hook_into :webmock
# end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
