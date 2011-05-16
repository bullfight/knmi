module KNMI
  class Parse
    class << self
      def json(station_object, parameter_object, data)
        parse(station_object, parameter_object, data)
      end
      
      def to_csv(filename, response)
        CSV.open(filename, "wb") do |csv|
          response[:data]
          csv << response[0].keys
          response[(1..(response.length - 1))].each do |line|
            csv << line.values
          end
        end
      end
    
    
    private 
    
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
      string_data = data.map {|row| row.map {|cell| cell.to_s } }
      data = string_data.map {|row| Hash[*header.zip(row).flatten] }
      
      # Parameter object array to hash
      p = []
      parameter_object.each {|e| p << e.detail }
            
      return {:station => station_object.detail, :parameters => p, :data => data}
    end
  end
end