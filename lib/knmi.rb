begin
  require 'httparty'
  require 'geokit'
  require 'csv'
rescue LoadError => e
  if require 'rubygems' then retry
  else raise(e)
  end
end

%w(station parameters httpservice calculations).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

module KNMI

  class << self
    
    # Get nearest station by lat lng
    #
    # @param lat [Numeric] - latitude e.g. 52.165
    # @param lng [Numeric] - longitude e.g. 4.419
    # @param [Array] [] - [lat, lng] e.g. [52.165, 4,419] *eqivalent to (lat, lng)*
    # @param [GeoKit::LatLng] - Geokit object e.g. GeoKit::LatLng.new(52.165, 4.419) *eqivalent to (lat, lng)*
    # @return [KNMI::Station] - Object with details about the station nearest to the requested lat/lng
    def station_by_location(lat, lng)
      Station.closest_to(lat, lng)
    end
    
    # Get station object by station ID
    #
    # @param station_id [String, Numeric] - number of station of interest, station_ids can be found in 
    # @return [KNMI::Station] - Object with details about the requested station
    def station_by_id(station_id)
      Station.find(station_id)
    end
    
    # Get an array of parameter objects
    #
    # All details in daily_data_key.yml and hourly_data_key.yml
    # @param [string] period - "daily" or "hourly"
    # @param [Array<string>] params - array of parameters e.g ["TX", "TG"]
    # @param [Array<string>] categories - array of categories e.g. ["WIND", "TEMP"]
    # @return [Array<KNMI::Parameters>] - array of KNMI::Parameters objects
    def parameters(period, params = nil, categories = nil)
      if params.nil? and categories.nil?
        list = Parameters.all(period)
      else
        list = []
        
        # Parameters by category
        list << Parameters.category(period, categories)
        list.flatten!
        
        # Parameters by name
        params = unique_params(params, list) #ensure params are unique to list 
        list << Parameters.find(period, params)        
        list.flatten!
        list.compact!
      end
      return list
    end
        
    #
    # Input a station object from KNMI.station_by_id or KNMI.station_by_location
    # and a parameter hash of objects from # KNMI.Parameters
    # return 
    def get_data(station_object, parameter_object, start_at = nil, end_at = nil, seasonal = false)
      if parameter_object[0].period == "daily"
        HttpService.get_daily(station_object, parameter_object, start_at, end_at, seasonal)
      elsif parameter_object[0].period == "hourly"
        HttpService.get_hourly(station_object, parameter_object, start_at, end_at, seasonal)
      end
    end
    
    # Input data request object and return array of hashes
    # data has been converted to operable units.
    def convert(request_object)
    
    
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