# frozen_string_literal: true

require 'bundler'
Bundler.require

require 'pathname'
Pathname.glob("#{__dir__}/../lib/*").sort.each { |file| require file }
