begin
  require 'httparty'
  require 'geokit'
  require 'csv'
rescue LoadError => e
  if require 'rubygems' then retry
  else raise(e)
  end
end

%w(station hourly daily httpservice parse).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

module KNMI

  class << self
    
    #
    # Get nearest station by lat lng
    # KNMI.station_by_location(52.165, 4.419) #=> #<KNMI::Station:0x0000010134e7f0>
    def station_by_location(lat, lng)
      Station.closest_to(lat, lng)
    end
    
    #
    # Get station object by station ID
    # KNMI.station_by_id(210) #=> #<KNMI::Station:0x000001016b9b38>
    def station_by_id(station_id)
      Station.find(station_id)
    end
    
    #
    # Generate array of daily parameter objects
    def daily_parameters(params = "", categories = "")
      if params.blank? and categories.blank?
        list = Daily.all
      else
        list = []
        
        # Parameters by category
        list << Daily.category(categories)
        list.flatten!
        
        # Parameters by name
        params = unique_params(params, list) #ensure params are unique to list 
        list << Daily.find(params)        
        list.flatten!
        list.compact!
      end
      return list
    end
    
    #
    # Generate array of hourly parameter objects
    def hourly_parameters(params = "", categories = "")
      if params.blank? and categories.blank?
        list = Daily.all
      else
        list = []
        
        # Parameters by category
        list << Daily.category(categories)
        list.flatten!
        
        # Parameters by name
        params = unique_params(params, list) #ensure params are unique to list 
        list << Daily.find(params)        
        list.flatten!
        list.compact!
      end
      return list
    end
    
    #
    # Input a station object from KNMI.station_by_id or KNMI.station_by_location
    # and a parameter hash of objects from # KNMI.daily_parameters or KNMI.hourly_parameters
    # return 
    def get_data(station_object, parameter_object)
      if parameter_object[0].period == "daily"
        HttpService.get_daily(station_object, parameter_object)
      elsif parameter_object[0].period == "hourly"
        HttpService.get_hourly(station_object, parameter_object)
      end
    end
    
    def parse_data(station_object, parameter_object, data)
      Parse.json(station_object, parameter_object, data)
    end
    
    private
    
    # Identify and eliminate overlap between params and categories
    def unique_params(params, list)
      list.each do |e|
        params = [params].flatten
        params.delete_if {|p| p == e.parameter }
      end
      return params
    end
    
  end
end