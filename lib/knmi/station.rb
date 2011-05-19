module KNMI
  class Station
    class <<self
      attr_writer :stations_file

      # Retrieve station object by id
      #
      # @param id [Numeric, String] - Station id
      # @return [KNMI::Station]
      #
      # @example Retrieve Station object for Valkenburg
      #   KNMI::Station.find(210)
      #
      def find(id)
        stations.find { |station| station.id == id }
      end

      # Find the station closest to a given location. Can accept arguments in any of the following
      # three forms (all are equivalent):
      #
      # @param *args [String, Array, Geokit::LatLLng]
      # @return [KNMI::Station] - Object with details about the station nearest to the requested lat/lng
      #
      # @example Retrieve Station by lat, lng
      #   KNMI::Station.closest_to(52.165, 4.419)
      #
      # @example Retrieve Station by [lat, lng]  
      #   KNMI::Station.closest_to([52.165, 4.419])
      #
      # @example Retrieve Station with GeoKit object
      #   KNMI::Station.closest_to(GeoKit::LatLng.new(52.165, 4.419))
      #
      def closest_to(*args)
        if args.length == 1
          if args.first.respond_to?(:distance_to)
            closest_to_coordinates(args.first)
          elsif %w(first last).all? { |m| args.first.respond_to?(m) }
            closest_to_lat_lng(args.first)
          else
            raise ArgumentError, "expected two-element Array or GeoKit::LatLng"
          end
        elsif args.length == 2
          closest_to_lat_lng(args)
        else
          raise ArgumentError, "closest_to() will accept one Array argument, one GeoKit::LatLng argument, or two FixNum arguments"
        end
      end

      private

      def closest_to_lat_lng(pair)
        closest_to_coordinates(GeoKit::LatLng.new(pair.first, pair.last))
      end

      def closest_to_coordinates(coordinates)
        stations.map do |station|
          [coordinates.distance_to(station.coordinates), station]
        end.min do |p1, p2|
          p1.first <=> p2.first # compare distance
        end[1]
      end

      def stations
        File.open(stations_file) do |file|
          yaml = YAML.load(file) || raise("Can't parse #{file.path} - be sure to run noaa-update-stations")
          yaml.map { |station_hash| new(station_hash) }
        end
      end

      def stations_file
        @stations_file ||= File.join(File.dirname(__FILE__), '..', '..', 'data', 'current_stations.yml')
      end
    end
    
    # @return [GeoKit::LatLng] - object containing the station's coordinates
    attr_reader :coordinates

    # @return [String] - Station ID (e.g., 210)
    attr_reader :id

    # @return [String] - Station name (e.g., "Valkenburg")
    attr_reader :name
    
    # @return [String] - Station Elevation
    attr_reader :elevation
    alias_method :elev, :elevation
    alias_method :altitude, :elevation
    alias_method :alt, :elevation
    
    # @return [String] - Link to Station Photo {http://www.knmi.nl/klimatologie/metadata/210_valkenburg_big.jpg Station 210 - Valkenburg Station Photo}
    attr_reader :photo
    
    # @return [String] - Link to map of station location {http://www.knmi.nl/klimatologie/metadata/stn_210.gif Station 210 - Valkenburg Station Map}
    attr_reader :map
    
    # @return [String] - Link to Metadata page listing http://www.knmi.nl/klimatologie/metadata/valkenburg.html {Station 210 - Valkenburg Station MetaData page}
    attr_reader :web
    
    # @return [Hash<Array>] - Hash containing arrays with detail about historical and current instrumentation at station
    attr_reader :instrumentation

    def initialize(properties)
      @id, @name, @elevation, @photo, @map, @web, @instrumentation = %w(id name elevation photo map web instrumentation).map do |p|
        properties[p]
      end
      @coordinates = GeoKit::LatLng.new(properties['lat'], properties['lng'])
    end
    
    # @return [Float] - Latitude of station
    def latitude
      @coordinates.lat
    end
    alias_method :lat, :latitude

    # @return [Float] - Longitude of station
    def longitude
      @coordinates.lng
    end
    alias_method :lng, :longitude
    alias_method :lon, :longitude
    
    
    # @return [Hash] - contains a has with detail about the station
    def detail
      {:id => @id, :name => @name, :elev => @elevation, :lat => latitude, :lng => longitude}    
    end
  end
end