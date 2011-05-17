require 'httparty'
module KNMI
  class HttpService 
    include HTTParty
    
    class << self
      
      def get_daily(station_object, parameter_object, start_at = nil, end_at = nil, seasonal = false)
        query = [station(station_object),  parameters(parameter_object), 
                 start_date(start_at)[0..13], end_date(end_at)[0..11],  # select YYYYMMDD (drops hour term)
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/climatology/daily_data/getdata_day.cgi', { :query => "#{query * "&"}" } )
        return new({"query" => query, "result" => result})
      end
  
      def get_hourly(station_number, params = "", start_at = nil, end_at = nil, seasonal = false)
        query = [station(station_number),  parameters(params), 
                 start_date(start_at), end_date(end_at), 
                 seasonal(seasonal)].compact
        result = get('http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi', { :query => "#{query * "&"}" } )
        return new({"query" => query, "result" => result})
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
      def end_date(ends)
        if ends.nil?
          t = Time.now
          "end" + time_str(t)
        elsif ends.kind_of?(Time)
          "end" + time_str(ends)
        end
      end
      
      def time_str(t)
        "=#{t.year}#{t.strftime("%m")}#{t.day}#{t.strftime("%H")}"
      end
    
    end
  
    #
    # Returns query string used in HTTP get request
    # KNMI::HttpService.get_daily(210) #=> @ query =>[ "stns=210", "vars=ALL", "start=2011051500", "end=2011051613"]
    attr_reader :query
  
    #
    # Returns result of HTTP get request
    # This is a text file with station and variable metadata as well as a csv of recorded values
    #
    # Example Response
    #
    ## THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED:
    ## ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE
    ##
    ## STN          LON         LAT       ALT  NAME
    ## 235:        4.79       52.92         5  DE KOOY    
    ##
    ## VVN   = Minimum opgetreden zicht / minimum visibility ...
    ## VVX   = Maximum opgetreden zicht / maximum visibility ...
    ## NG    = Bedekkingsgraad van de bovenlucht / cloud cover in octants (9=sky invisible)
    ## DR    = Duur van de neerslag / precipitation duration in 0.1 hour
    ## RH    = Etmaalsom van de neerslag / daily precipitation amount in 0.1 mm (-1 for <0,05 mm)
    ## EV24  = Referentiegewasverdamping (Makkink)/  Potential evapotranspiration (Makkink) in 0.1 mm
    ##
    ## STN,YYYYMMDD,  VVN,  VVX,   NG,   DR,   RH, EV24
    ##
    #  235,19700101,   60,   65,    4,    0,    0,    4
    #  235,19700102,   30,   75,    8,   14,   21,    2
    #  235,19700103,   60,   70,    5,    2,    5,    3    
    attr_reader :result
  
    def initialize(properties)
      @query, @result = %w(query result).map do |p|
        properties[p]
      end
    end
  end
end
