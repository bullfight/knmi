require 'httparty'
require 'csv'


%w(station).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

module KNMI
  