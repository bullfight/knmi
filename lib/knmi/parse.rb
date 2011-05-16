module KNMI
  class Parse
    class << self
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
        stations = stations.split(/\r/)      
        temp = []
        stations.each do |x|
          temp << [x.lstrip.split(/\s{2,}/)].flatten
        end      
        stations = temp
        st_header = [:station_code, :lng, :lat, :elev, :name]      
        stations = stations.map {|row| Hash[*st_header.zip(row).flatten] }
        stations.each do |x|
          x[:name] = x[:name].capitalize
        end

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
        response = response.join.tr("\s+", "")
        response = response.tr("#", "")

        # Parse into array and then hash with var name
        response = CSV.parse(response, {:skip_blanks => true})
        header = response.shift.map {|i| i.to_s.intern }
        string_data = response.map {|row| row.map {|cell| cell.to_s } }
        data = string_data.map {|row| Hash[*header.zip(row).flatten] }

        return {:stations => stations, :variables => varlist, :data => data}
      end
    end    
  end
end