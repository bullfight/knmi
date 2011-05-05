require 'httparty'
require 'csv'

class KNMI
  include HTTParty
  base_uri 'http://www.knmi.nl/climatology/daily_data/getdata_day.cgi'
    
  class << self
    private :new
    
    # station1:station2:station15 requires station or list of stations NO DEFAULT
    def station(station_number) 
      if station_number.nil? == true
        raise "Station Number Required" # doesn't work look into this
      elsif station_number.kind_of?(Array)
        "stns=#{station_number * ":"}"
      else
        "stns=#{station_number}"
      end
    end
    
    def check_stations
      # stubbed out complete later
    end
    
    # YYYYMMDD Default is first day of current month
    def start_date(_start)
      "start=#{_start}"
    end
    
    # YYYYMMDD Default is current or last recorded day
    def end_date(_end)
      "end=#{_end}"
    end

    def variables(vars)
            
      if vars.empty? == true
        "vars=ALL"
      else      
        vars, nvars = check_variables(vars)
        "vars=#{vars * ":"}"        
      end    
    end
  
	  # Delete Invalid Variables and keep those valid, if none are valid replace with all
    def check_variables(vars)

      if vars.kind_of?(Array) == false 
        vars = [vars]
      end
  
      # Collections of variables and all Possible Variables
      varOpts = {
        "WIND" => ["DDVEC", "FG", "FHX", "FHX", "FX"], 
        "TEMP" => ["TG", "TN", "TX", "T10N"], 
        "SUNR" => ["SQ", "SP", "Q"],
        "PRCP" => ["DR", "RH", "EV24"],
        "PRES" => ["PG", "PGX", "PGN"],
        "VICL" => ["VVN", "VVX", "NG"],
        "MSTR" => ["VVN", "VVX", "NG"],
        "ALL"  => ["DDVEC", "FHVEC", "FG", "FHX", 
                   "FHXH", "FHN", "FHNH", "FXX", "FXXH", "TG", "TN", 
                   "TNH", "TX", "TXH", "T10N", "T10NH", "SQ", "SP", 
                   "Q", "DR", "RH", "RHX", "RHXH", "EV24", "PG", "PX", 
                   "PXH", "PN", "PNH", "VVN", "VVNH", "VVX", "VVXH", 
                   "NG", "UG", "UX", "UXH", "UN", "UNH"]
      }

        # Drop in invalid vars
       vars = ( vars & varOpts.to_a.flatten )

       # Only Allow Variable to be selected once, All, or TEMP, not ALL & TEMP
       # And count the number of selected variables
    	if vars.include?("ALL") == true or vars.empty? == true
	      vars = "ALL"
	      nvars = varOpts["ALL"].count
    	elsif (vars & varOpts.keys) # check if contains keys

	      x = []
	      (vars & varOpts.keys).each do |k|
	        x << varOpts.values_at(k)
	      end
	      vars = (vars - x.flatten)

	      nvars = 0
	      ( vars & varOpts.keys ).each do |v|
	        nvars += varOpts[v].count
	      end

	      ( vars - varOpts.keys ).each do |v|
	        nvars += 1
	      end      
    	end

      return vars, nvars
    end
    
    # Parse Response into hashed arrays
    #Other elements
    #varlist = res[(7+nstn)..(6 + nstn + nvars)]
    #colheader = res[(8 + nstn + nvars)]
    #header = res[0..(9 + nstn + nvars)]
    def parse(response, station_number, vars)
      # Line Index Numbers
      nstn = [station_number].flatten.length
      vars, nvars = check_variables(vars)
      
      # Split lines into array
      response = response.split(/\n/)

      # Get Station Details
      stations = response[5..(4+nstn)]
      stations = stations.join.tr("\t", "\s")
      stations = stations.tr("#", "")
      stations = stations.tr(":", "")
      stations = CSV.parse( stations, {:col_sep => "\s"} )
      stations = stations.map {|row| row.map {|cell| cell.to_s } }
      st_header = [:station_code, :lng, :lat, :elev, :name]
      stations = stations.map {|row| Hash[*st_header.zip(row).flatten] }

      # Get Variable Details
      varlist = response[(7+nstn)..(6 + nstn + nvars)]
      varlist = varlist.join
      varlist = varlist.gsub(/# /, "")
      varlist = varlist.gsub(/\s{2,}/, "")
      varlist = varlist.gsub(/;/, "\r")
      varlist = CSV.parse( varlist, {:col_sep => "= "} )
      vr_header = [:var, :description]
      varlist = varlist.map {|row| Hash[*vr_header.zip(row).flatten] }

      # Get and clean data
      response = response[(8 + nstn + nvars)..response.length]
      response[0] = response[0].sub(/\r/, "")
      response = response.join.tr("\s+", "")
      response = response.tr("#", "")

      # Parse into array and then hash with var name
      response = CSV.parse(response, {:skip_blanks => true})
      header = response.shift.map {|i| i.to_s.intern }
      string_data = response.map {|row| row.map {|cell| cell.to_s } }
      data = string_data.map {|row| Hash[*header.zip(row).flatten] }

      return {:stations => stations, :variables => varlist, :data => data}
    end
  end # End Private
   
  # gets variables from station or list of stations
  # with all variables if vars is empty or selected variables passed as an array
  # data is from begining of current month to current day
  # Example
  # station_number = [210, 212]
  # vars = "TG"
  # res = KNMIdaily.get_station( station_number, vars )
  # output {:stations => {:}}
  def self.get_station(station_number, vars = "")
    query = station(station_number) + "&" + variables(vars)
    puts query 
    res = get("", { :query => query } )
    res = parse(res, station_number, vars)
  end
  
  # gets variables from station or list of stations
  # with all variables if vars is empty or selected variables passed as an array
  # data is from start date to current
  def self.get_station_start_to_current(station_number, start, vars = "")
    query = station(station_number) + "&" + start_date(start) + "&" + variables(vars)
    puts query
    res = get("", { :query => query } )
    res = parse(res, station_number, vars)
  end
  
  # gets variables from station or list of stations
  # with all variables if vars is empty or selected variables passed as an array
  # data is from start date to end date
  def self.get_station_range(station_number, _start, _end, vars = "")
    query = station(station_number) + "&" + start_date(_start) + "&" + end_date(_end) + "&" + variables(vars)
    puts query
    res = get("", { :query => query } )
    res = parse(res, station_number, vars)
  end
  
  # gets variables from station or list of stations
  # with all variables if vars is empty or selected variables passed as an array
  # seasonal data is from start date to end date 
  # by selected month and day within each year
  def self.get_seasonal(station_number, _start, _end, vars = "")
    query = station(station_number) + "&" + "inseason=true" + "&" + start_date(_start) + "&" + end_date(_end) + "&" + variables(vars)
    puts query
    get("", { :query => query } )
  end
  
  def self.to_csv(filename, response)
    CSV.open(filename, "wb") do |csv|
      response[:data]
      csv << response[:data][0].keys
      response[(1..(response[:data].length - 1))].each do |line|
        csv << line.values
      end
    end
  end

end