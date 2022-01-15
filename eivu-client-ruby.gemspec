# frozen_string_literal: true

Gem::Specification.new do |s|
  s.authors = ['Robert Jenkins']
  s.email   = ['me@rkj3.com']

  s.name = 'eivu-client-ruby'
  s.version = '0.1.0'

  s.license          = 'MIT'
  s.homepage         = 'https://github.com/eivu/client-ruby'

  s.platform = Gem::Platform::RUBY
  s.summary = 'Ruby wrapper for the AcoustID service'
#   s.description = <<-EOD
# Ruby client for the eivu service
#   EOD
  s.files         = ['lib/eivu.rb']
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0', '>= 7.0.1'
  s.add_dependency 'aws-sdk-s3', '~> 1.111', '>= 1.111.1'
  s.add_dependency 'dry-struct', '~> 1.4' # structs with default values
  s.add_dependency 'nokogiri', '~> 1.13', '>= 1.13.1' # xml parser
  s.add_dependency 'oj', '~> 3.3', '>= 3.3.5' # faster json parsing
  s.add_dependency 'pry', '~> 0.14.1' # Debugger
  s.add_dependency 'rest-client', '~> 2.1' # A simple HTTP and REST client for Ruby, inspired by the Sinatra microframework style of specifying actions
  s.add_dependency 'rspec', '~> 3.10' # testing lib
  s.add_dependency 'vcr', '~> 6.0' # VCR for testing
  s.add_dependency 'zeitwerk', '~> 2.5', '>= 2.5.3' # ruby autoloder


  # s.files = `git ls-files`.split "\n"
  # s.test_files = `git ls-files -- {test,spec,features}/*`.split "\n"
  # s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename f }
  # s.require_paths = ['lib']

  # s.required_ruby_version = '>= 2.4.0'

  # s.add_dependency 'ice_cube', '~> 0.16'

  # s.add_development_dependency 'rake', '~> 13.0'
  # s.add_development_dependency 'bundler', '~> 2.0'

  # # test with all groups of tzinfo dependencies
  # # tzinfo 2.x
  # # s.add_development_dependency 'tzinfo', '~> 2.0'
  # # s.add_development_dependency 'tzinfo-data', '~> 1.2020'
  # # tzinfo 1.x
  # s.add_development_dependency 'activesupport', '~> 6.0'
  # s.add_development_dependency 'i18n', '~> 1.8'
  # s.add_development_dependency 'tzinfo', '~> 1.2'
  # s.add_development_dependency 'tzinfo-data', '~> 1.2020'
  # # tzinfo 0.x
  # # s.add_development_dependency 'tzinfo', '~> 0.3'
  # # end tzinfo

  # s.add_development_dependency 'timecop', '~> 0.9'
  # s.add_development_dependency 'rspec', '~> 3.8'
  # s.add_development_dependency 'simplecov', '~> 0.16'
end