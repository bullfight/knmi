require 'httparty'
module KNMI
  class HttpService 
    include HTTParty
    
    class << self
      
      def get_daily(station_object, parameter_object, start_at = nil, end_at = nil, seasonal = false)
        # select YYYYMMDD (drops hour term)
        query = [station(station_object),  parameters(parameter_object), 
                 start_date(start_at)[0..13], end_date(end_at)[0..11],
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/climatology/daily_data/getdata_day.cgi', { :query => "#{query * "&"}" } )
        
        data = parse(station_object, parameter_object, result)
        
        return new({"query" => query, "data" => data})
      end
  
      def get_hourly(station_object, parameter_object, start_at = nil, end_at = nil, seasonal = false)
        query = [station(station_object),  parameters(parameter_object), 
                 start_date(start_at), end_date(end_at),
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi', { :query => "#{query * "&"}" } )
        
        data = parse(station_object, parameter_object, result)
        
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
  
    #
    # Returns query string used in HTTP get request
    # KNMI::HttpService.get_daily(210) #=> @ query =>[ "stns=210", "vars=ALL", "start=2011051500", "end=2011051613"]
    attr_reader :query
  
    #
    # Parsed HTTP request
    # Array of Hashes     
    attr_reader :data
  
    def initialize(properties)
      @query, @data = %w(query data).map do |p|
        properties[p]
      end
    end
  end
end
