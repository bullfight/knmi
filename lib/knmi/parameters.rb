module KNMI
  class Parameters
    class << self
      attr_writer :keys_file
      
      #
      # Retrieve information about Parameter can be string or array
      #
      # KNMI::Parameter.find(period = "daily", "TA")  #=> KNMI::Parameter object for TG (Daily Max temperature)
      # KNMI::Parameter.find(period = "daily", ["TG", "TX"])  #=> KNMI::Parameter array of objects TG (Daily Mean temperature) and TX (Daily Max Temperature)
      def find(period, parameter)
        parameter = [parameter].flatten
        
        list = []
        parameter.uniq.each do |p|
          list << keys.find { |k| k.parameter == p and k.period == period }
        end
        
        return list
      end     
      
      #
      # Retrieve each parameter within a category
      # an Array of structs
      #
      # KNMI.Parameter.category(period = "daily, ""WIND") #=> [#<Parameter:0x00000100b433f8 @parameter="SQ", @category="RADT", @description="Sunshine Duration", @validate="(-1..6).include?(n)", @conversion="n == -1 ? 0.05 : (n / 10) * 60", @units="minutes">, #<Daily:0x00000100b43290 @parameter="SP", @category="RADT", @description="Percent of Maximum Sunshine Duration", @validate="(0..100).include?(n)", @conversion=nil, @units="%">, #<Daily:0x00000100b43128 @parameter="Q", @category="RADT", @description="Global Radiation", @validate="n.integer?", @conversion=nil, @units="J/cm^2">]
      # KNMI.Parameter.category(period = "daily, ["WIND", "TEMP"]) 
      def category(period, category)        
        category = [category].flatten
        
        list = []
        category.uniq.each do |c|
          list << keys.select { |k| k.category == c and k.period == period }
        end
        
        return list.flatten!
      end
      
      #
      # Retrieve all Parameters
      # an Array of structs
      def all(period)      
        list = []
        list << keys.select { |k| k.period == period }
        list.flatten!
      end
      
      private
            
      # Parameters
      def keys
        File.open(keys_file) do |file|
          yaml = YAML.load(file) || raise("Can't parse #{file.path}")
          yaml.map { |key_hash| new(key_hash) }
        end
      end

      def keys_file
        @keys_file ||= File.join(File.dirname(__FILE__), '..', '..', 'data', 'data_key.yml')
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
    
    # Time Period
    attr_reader :period
    
    def initialize(properties)
      @parameter, @category, @description, @validate, @conversion, @units, @period = %w(parameter category description validate conversion units period).map do |p|
        properties[p]
      end
    end
    
    def detail
      {:parameter => @parameter, :category => @category, 
       :description => @description, :validate => @validate, 
       :conversion => @conversion, :units => @units, :period => @period}
    end

  end
end