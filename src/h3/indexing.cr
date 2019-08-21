require "./bindings/base"

module Indexing
    include H3::Bindings::Base
    # include H3::Bindings::Types
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
    def from_geo_coordinates(coords : Tuple(Float64, Float64), resolution : Resolution) : UInt64
      lat, lon = coords

      if lat > 90 || lat < -90 || lon > 180 || lon < -180
        raise("Invalid coordinates")
      end

      geo_coords = LibH3::GeoCoord.new(
        lat: LibH3.degs_to_rads(lat),
        lon: LibH3.degs_to_rads(lon)
      )
      
      LibH3.geo_to_h3(pointerof(geo_coords), resolution.value)
    end

    # Derive coordinates for a given H3 index.
    #
    # The coordinates map to the centre of the hexagon at the given index.
    #
    # @param [Integer] h3_index A valid H3 index.
    #
    # @example Derive the central coordinates for the given H3 index.
    #   H3.to_geo_coordinates(617439284584775679)
    #   [52.245519061399506, -1.7363137757391423]
    #
    # @return [Array<Integer>] A coordinate pair.
    def to_geo_coordinates(h3_index : UInt64) : Tuple(Float64, Float64)
      LibH3.h3_to_geo(h3_index, out coords)

      {LibH3.rads_to_degs(coords.lat), LibH3.rads_to_degs(coords.lon)}
    end
end