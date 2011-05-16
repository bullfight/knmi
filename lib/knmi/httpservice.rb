require 'httparty'
module KNMI
  class HttpService #:nodoc:
    include HTTParty
        
    def self.get_daily(station_number, params = "", start_at = "", end_at = "", seasonal = false)
      query = [station(station_number),  parameters(params), start_date(start_at), end_date(end_at), seasonal(seasonal)].compact
      puts "#{query * "&"}"
      #get('http://www.knmi.nl/climatology/daily_data/getdata_day.cgi', { :query => "#{query * "&"}" } )
    end
  
    def get_hourly(station_number, params, _start, _end, seasonal = false)
      query = [station(station_number),  parameters(params), start_date(start_at), end_date(end_at), seasonal(seasonal)].compact
      get('http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi', { :query => "#{query * "&"}" } )
    end
    
    class << self
      private :new
    
      # Generates string for station list    
      # station1:station2:station15 requires station or list of stations NO DEFAULT
      def station(station_number) 
        if station_number.kind_of?(Array)
          "stns=#{station_number * ":"}"
        else
          "stns=#{station_number}"
        end
      end
    
      def seasonal(bool)
        if bool == false
          nil
        else
          "inseason=true"
        end
      end
    
      # YYYYMMDD Default is first day of current month
      def start_date(_start)
        if _start.empty?
          nil
        else
          "start=#{_start}"
        end
      end
    
      # YYYYMMDD Default is current or last recorded day
      def end_date(_end)
        if _end.empty?
          nil
        else
          "end=#{_end}"
        end
      end
    
      def parameters(params)
        if params.empty?
          "vars=ALL"
        else      
          "vars=#{vars * ":"}"        
        end    
      end    
    end
  end
end
