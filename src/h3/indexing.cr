require "./bindings/base"

module Indexing
    extend H3::Bindings::Base
    # Derive H3 index for the given set of coordinates.
    #
    # @param [Array<Integer>] coords A coordinate pair.
    # @param [Integer] resolution The desired resolution of the H3 index.
    #
    # @example Derive the H3 index for the given coordinates.
    #   H3.from_geo_coordinates([52.24630137198303, -1.7358398437499998], 9)
    #   617439284584775679
    #
    # @raise [ArgumentError] If coordinates are invalid.
    #
    # @return [Integer] H3 index.
    def from_geo_coordinates(coords : Tuple(Float64, Float64), resolution : Int32) : UInt64
      lat, lon = coords

      if lat > 90 || lat < -90 || lon > 180 || lon < -180
        raise("Invalid coordinates")
      end

      geo_coords = LibH3::GeoCoord.new
      geo_coords.lat = LibH3.degs_to_rads(lat)
      geo_coords.lon = LibH3.degs_to_rads(lon)
      puts "Coords: #{geo_coords}, Resolution: #{resolution}"
    #   Bindings::Private.geo_to_h3(coords, resolution)
      # puts "Resolution: #{resolution}"
      return LibH3.geo_to_h3(pointerof(geo_coords), resolution)
    end
end