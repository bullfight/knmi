module KNMI
  class Parameters
    class << self
      attr_writer :keys_file
      
      # Retrieve Parameter Object by named parameter
      #
      # @param period [String] - "daily" or "hourly"
      # @param parameter [Array, String] - Array of strings or string of parameter name
      # @return [Array<KNMI::Parameters>] - array of parameter objects
      #
      # @example
      #   KNMI::Parameter.find(period = "daily", "TA")  
      #   KNMI::Parameter.find(period = "daily", ["TG", "TX"])
      #
      def find(period, parameter)
        parameter = [parameter].flatten
        
        list = []
        parameter.uniq.each do |p|
          list << keys.find { |k| k.parameter == p and k.period == period }
        end
        
        return list
      end     
      
      # Retrieve Parameter Object by named parameter
      #
      # @param period [String] - "daily" or "hourly"
      # @param category [Array, String] - Array of strings or string of category name
      # @return [Array<KNMI::Parameters>] - array of parameter objects
      #
      # @example
      #   KNMI.Parameter.category(period = "daily, ""WIND")
      #   KNMI.Parameter.category(period = "daily, ["WIND", "TEMP"])
      #
      def category(period, category)        
        category = [category].flatten
        
        list = []
        category.uniq.each do |c|
          list << keys.select { |k| k.category == c and k.period == period }
        end
        
        return list.flatten!
      end
      
      # Retrieve all Parameters
      # @param period [String] - "daily" or "hourly"
      # @return [Array<KNMI::Parameters>] - array of parameter objects
      #
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
    
    # @return [String] - Paramter shortname
    attr_reader :parameter
    
    # @return [String] - Categories grouping parameters
    attr_reader :category
    
    # @return [String] - Description of parameter
    attr_reader :description 
    
    # @return [String] - example code to validate data as accurate
    attr_reader :validate
    
    # @return [String] - example code to convert data into appropriate format/units for operation
    attr_reader :conversion
    
    # @return [String] - Unit of converted format
    attr_reader :units 
    
    # @return [String] - Time Period "daily" or "hourly"
    attr_reader :period
    
    def initialize(properties)
      @parameter, @category, @description, @validate, @conversion, @units, @period = %w(parameter category description validate conversion units period).map do |p|
        properties[p]
      end
    end
    
    # @return [Hash] - Hash containing important details about parameters object
    def detail
      {:parameter => @parameter, :category => @category, 
       :description => @description, :validate => @validate, 
       :conversion => @conversion, :units => @units, :period => @period}
    end

  end
end