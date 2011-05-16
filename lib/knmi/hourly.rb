module KNMI
  class Hourly
    class << self
      attr_writer :hourly_key
      
      # Retrieve information about Parameter
      #
      # KNMI::Hourly.find("T")  #=> KNMI::Station object for T (Air Temperature)
      def find(parameter)
        hourly.find { |hourly| hourly.parameter == parameter }
      end
      
      # Retrieve each parameter within a category
      # an Array of structs
      #
      # KNMI::Hourly.category("WIND") #=> 
      def category(category)
        hourly.select { |hourly| hourly.category == category }
      end
      
      # Retrieve all Parameters
      # an Array of structs
      def all
        hourly
      end
      
      private
      
      def hourly
        File.open(hourly_key) do |file|
          yaml = YAML.load(file) || raise("Can't parse #{file.path}")
          yaml.map { |hourly_hash| new(hourly_hash) }
        end
      end

      def hourly_key
        @hourly_key ||= File.join(File.dirname(__FILE__), '..', '..', 'data', 'hourly_data_key.yml')
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