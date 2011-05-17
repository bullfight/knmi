begin
  require 'httparty'
  require 'geokit'
  require 'csv'
rescue LoadError => e
  if require 'rubygems' then retry
  else raise(e)
  end
end

%w(station parameters httpservice).each { |file| require File.join(File.dirname(__FILE__), 'knmi', file) }

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
    # Generate array of unique daily or hourly parameter objects
    # All details in daily_data_key.yml and hourly_data_key.yml
    # inputs 
    # period = "daily" or "hourly" 
    # params =  
    # categories =
    
    def parameters(period, params = "", categories = "")
      if params.blank? and categories.blank?
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