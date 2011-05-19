require 'httparty'
module KNMI
  class HttpService 
    include HTTParty
    
    class << self
      
      # Requests Daily data
      #
      # @param station_object [KNMI::Station] - Station Object
      # @param parameter_object [KNMI::Parameters] - Parameter Object
      # @param starts [Time] - Time Object
      # @param ends [Time] - Time Object
      # @param seasonal [Boolean]
      # @return [KNMI::HttpService]
      #
      def get_daily(station_object, parameters_object, starts = nil, ends = nil, seasonal = false)
        # select YYYYMMDD (drops hour term)
        query = [station(station_object),  parameters(parameters_object), 
                 start_date(starts)[0..13], end_date(ends)[0..11],
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/climatology/daily_data/getdata_day.cgi', { :query => "#{query * "&"}" } )
        
        data = parse(station_object, parameters_object, result)
        
        return new({"query" => query, "data" => data})
      end
      
      # Requests Hourly data
      #
      # @param station_object [KNMI::Station] - Station Object
      # @param parameter_object [KNMI::Parameters] - Parameter Object
      # @param starts [Time] - Time Object
      # @param ends [Time] - Time Object
      # @param seasonal [Boolean]
      # @return [KNMI::HttpService]
      #
      def get_hourly(station_object, parameters_object, starts = nil, ends = nil, seasonal = false)
        query = [station(station_object),  parameters(parameters_object), 
                 start_date(starts), end_date(ends),
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi', { :query => "#{query * "&"}" } )
        
        data = parse(station_object, parameters_object, result)
        
        return new({"query" => query, "data" => data})
      end
        
      private
    
      # Generates string for station 
      def station(station_object) 
        "stns=#{station_object.id}"
      end
    
      # pulls parameter names from parameter object defaults to All
      def parameters(parameter_object)
        vars = []
        parameter_object.each { |p| vars << p.parameter }                    
        "vars=#{vars * ":"}"
      end      
  
      # Select Data seasonally? between selected dates for each year.
      def seasonal(bool)
        if bool == false
          nil
        else
          "inseason=true"
        end
      end
  
      # YYYYMMDDHH Default is previous day
      # if starts is nil returns string for one day prior to current
      def start_date(starts)
        if starts.nil?
          t = Time.now
          t = Time.utc(t.year, t.month, t.day)
          t = t - 24 * 60 * 60  
          "start" + time_str(t)
        elsif starts.kind_of?(Time)
          "start" + time_str(starts)
        end
      end
  
      # YYYYMMDDHH Default is current day
      # if ends is nil returns string for current time
      def end_date(ends)
        if ends.nil?
          "end" + time_str(Time.now)
        elsif ends.kind_of?(Time)
          "end" + time_str(ends)
        end
      end
      
      # Hours requires 01-24
      def time_str(t)
        hour = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
        "=#{t.year}#{t.strftime("%m")}#{t.day}#{hour[t.hour]}"
      end
      
      # Grab the Http response data and convert to array of hashes
      def parse(station_object, parameter_object, data)
        # Number stations
        nstn = 1
        # Number parameters
        nparams = parameter_object.length

        # Split lines into array
        data = data.split(/\n/)

        # Get and clean data
        data = data[(8 + nstn + nparams)..data.length]
        data = data.join.tr("\s+", "")
        data = data.tr("#", "")

        # Parse into array and then hash with var name
        data = CSV.parse(data, {:skip_blanks => true})
        header = data.shift.map {|i| i.to_s.intern }
        string_data = data.map {|row| row.map {|cell| cell.to_i } }
        data = string_data.map {|row| Hash[*header.zip(row).flatten] }
      
        return data
      end
    
    end
  
    # Returns query string used in HTTP get request
    #
    # @return [Array<string>] - array of strings which contains the components used in the HTTP request
    #
    # @example
    #   KNMI::HttpService.get_daily(station, parameter).query
    #   =>[ "stns=210", "vars=ALL", "start=2011051500", "end=2011051613"]
    attr_reader :query
  
    # Parsed HTTP request
    #
    # @return [Array<Hash>] - array of hashes which contains climate data in storage(integer) format
    # @example
    #   KNMI::HttpService.get_daily(station, parameter).data
    #   =>[{:STN=>"235", :YYYYMMDD=>"20100628", :TX=>"263"}, {:STN=>"235", :YYYYMMDD=>"20100629", :TX=>"225"}]
    attr_reader :data
  
    def initialize(properties)
      @query, @data = %w(query data).map do |p|
        properties[p]
      end
    end
  end
end
