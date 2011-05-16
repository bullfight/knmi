module KNMI
  class Daily
    class << self
      attr_writer :daily_key
      
      # Retrieve information about Parameter
      #
      # KNMI::Daily.find("TA")  #=> KNMI::Station object for TG (Daily Max temperature)
      def find(parameter)
        daily.find { |daily| daily.parameter == parameter }
      end
      
      # Retrieve each parameter within a category
      # an Array of structs
      #
      # KNMI.Daily.category("WIND") #=> [#<Daily:0x00000100b433f8 @parameter="SQ", @category="RADT", @description="Sunshine Duration", @validate="(-1..6).include?(n)", @conversion="n == -1 ? 0.05 : (n / 10) * 60", @units="minutes">, #<Daily:0x00000100b43290 @parameter="SP", @category="RADT", @description="Percent of Maximum Sunshine Duration", @validate="(0..100).include?(n)", @conversion=nil, @units="%">, #<Daily:0x00000100b43128 @parameter="Q", @category="RADT", @description="Global Radiation", @validate="n.integer?", @conversion=nil, @units="J/cm^2">]
      def category(category)
        daily.select { |daily| daily.category == category }
      end
      
      # Retrieve all Parameters
      # an Array of structs
      def all
        daily        
      end
      
      private
      
      def daily
        File.open(daily_key) do |file|
          yaml = YAML.load(file) || raise("Can't parse #{file.path}")
          yaml.map { |daily_hash| new(daily_hash) }
        end
      end

      def daily_key
        @daily_key ||= File.join(File.dirname(__FILE__), '..', '..', 'data', 'daily_data_key.yml')
      end      
    end
    
    # Paramter shortname
    attr_reader :parameter
    
    # Categories grouping parameters
    attr_reader :category
    
    # Description of parameter
    attr_reader :description 
    
    # Code to validate data as accurate
    attr_reader :validate
    
    # Code to convert data into appropriate format/units
    attr_reader :conversion
    
    # Unit of converted format
    attr_reader :units 
    
    def initialize(properties)
      @parameter, @category, @description, @validate, @conversion, @units = %w(parameter category description validate conversion units).map do |p|
        properties[p]
      end
    end
    
  end
end