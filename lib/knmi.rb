require 'httparty'
require 'csv'

%w(check_variables).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

module KNMI

  class << self
    def intialize(station_number, vars = "")

      @station_number = station_number
      @vars = vars

    end
  end
end