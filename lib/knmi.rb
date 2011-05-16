begin
  require 'httparty'
  require 'geokit'
  require 'csv'
rescue LoadError => e
  if require 'rubygems' then retry
  else raise(e)
  end
end

%w(station hourly daily httpservice).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

module KNMI

  class << self
    def station_by_location(lat, lng)
      Station.closest_to(lat, lng).id
    end
    
    def station_by_id(station_id)
      Station.select(station_id)
    end
    
    def daily_parameters(params = "", categories = "")
      if params.blank? and categories.blank?
        Daily.all
      else      
        Daily.find(params)
        Daily.category(categories)
    end
    
  end
end