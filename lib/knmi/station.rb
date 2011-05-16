module KNMI
  class Station
    class <<self
      attr_writer :stations_file #:nodoc:

      #
      # Retrieve information about a station given a station ID
      #
      #   KNMI::Station.find(210)  #=> KNMI::Station object for Valkenburg
      def find(id)
        stations.find { |station| station.id == id }
      end

      # 
      # Find the station closest to a given location. Can accept arguments in any of the following
      # three forms (all are equivalent):
      #
      #   KNMI::Station.closest_to(52.165, 4.419)
      #   KNMI::Station.closest_to([52.165, 4.419])
      #   KNMI::Station.closest_to(GeoKit::LatLng.new(52.165, 4.419))
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

    # GeoKit::LatLng containing the station's coordinates
    attr_reader :coordinates

    # Station ID (e.g., 210)
    attr_reader :id

    # Station name (e.g., "New York City, Central Park")
    attr_reader :name
    
    # Station Elevation
    attr_reader :elevation
    alias_method :elev, :elevation
    alias_method :altitude, :elevation
    alias_method :alt, :elevation
    
    # Link to Station Photo
    attr_reader :photo
    
    # Link to map of station location
    attr_reader :map
    
    # Link to Metadata page listing
    attr_reader :web
    
    attr_reader :instrumentation

    def initialize(properties)
      @id, @name, @elevation, @photo, @map, @web, @instrumentation = %w(id name elevation photo map web instrumentation).map do |p|
        properties[p]
      end
      @coordinates = GeoKit::LatLng.new(properties['lat'], properties['lng'])
    end
    
    # Latitude of station
    def latitude
      @coordinates.lat
    end
    alias_method :lat, :latitude

    # Longitude of station
    def longitude
      @coordinates.lng
    end
    alias_method :lng, :longitude
    alias_method :lon, :longitude
  end
end