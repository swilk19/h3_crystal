require "geojson"
require "../h3"

module H3
  # GeoJSON integration for H3 polygon operations.
  #
  # This module provides convenience methods to convert between GeoJSON
  # Polygon/MultiPolygon geometries and H3 polyfill operations.
  #
  # This is an optional integration. To use it, consumers must add the
  # `geojson` shard to their dependencies and require this file explicitly:
  #
  #   require "h3_crystal/h3/geojson"
  #
  # @example Fill a GeoJSON Polygon with H3 cells
  #   polygon = GeoJSON::Polygon.new([
  #     [[-122.4089866, 37.813318], [-122.3805436, 37.7866302],
  #      [-122.3544736, 37.7198061], [-122.5123436, 37.7076131],
  #      [-122.4089866, 37.813318]]
  #   ])
  #   cells = H3.polygon_to_cells(polygon, 9)
  #
  # @example Convert H3 cells to a GeoJSON MultiPolygon
  #   cells = H3.polygon_to_cells(polygon, 9)
  #   multi_polygon = H3.cells_to_geojson_multi_polygon(cells)
  module GeoJSON
    # Fill a GeoJSON::Polygon with H3 cells at the specified resolution.
    #
    # The GeoJSON Polygon's exterior ring is used as the outer boundary.
    # Any additional rings are treated as holes.
    #
    # GeoJSON coordinates are in [longitude, latitude] order per RFC 7946.
    # These are converted to the (latitude, longitude) tuples expected by H3.
    #
    # @param [::GeoJSON::Polygon] polygon A GeoJSON Polygon geometry.
    # @param [Integer] resolution The desired H3 resolution (0-15).
    # @param [UInt32] flags Containment mode flags (default 0 = center containment).
    #
    # @example Fill a GeoJSON polygon with H3 cells at resolution 9.
    #   polygon = GeoJSON::Polygon.new([
    #     [[-122.4089866, 37.813318], [-122.3805436, 37.7866302],
    #      [-122.3544736, 37.7198061], [-122.5123436, 37.7076131],
    #      [-122.4089866, 37.813318]]
    #   ])
    #   H3.polygon_to_cells(polygon, 9)
    #
    # @return [Array<UInt64>] Array of H3 indexes filling the polygon.
    def polygon_to_cells(polygon : ::GeoJSON::Polygon, resolution : Int32, flags : UInt32 = 0_u32) : Array(UInt64)
      outer, holes = geojson_polygon_to_h3_coords(polygon)
      H3.polygon_to_cells(outer, resolution, holes: holes, flags: flags)
    end

    # Fill a GeoJSON::MultiPolygon with H3 cells at the specified resolution.
    #
    # Each sub-polygon is filled independently and the results are combined,
    # with duplicates removed.
    #
    # @param [::GeoJSON::MultiPolygon] multi_polygon A GeoJSON MultiPolygon geometry.
    # @param [Integer] resolution The desired H3 resolution (0-15).
    # @param [UInt32] flags Containment mode flags (default 0 = center containment).
    #
    # @example Fill a GeoJSON MultiPolygon with H3 cells at resolution 7.
    #   multi_polygon = GeoJSON::MultiPolygon.new([polygon1, polygon2])
    #   H3.polygon_to_cells(multi_polygon, 7)
    #
    # @return [Array<UInt64>] Array of H3 indexes filling all polygons.
    def polygon_to_cells(multi_polygon : ::GeoJSON::MultiPolygon, resolution : Int32, flags : UInt32 = 0_u32) : Array(UInt64)
      cells = Set(UInt64).new
      multi_polygon.coordinates.each do |polygon_rings|
        outer, holes = geojson_rings_to_h3_coords(polygon_rings)
        H3.polygon_to_cells(outer, resolution, holes: holes, flags: flags).each do |cell|
          cells.add(cell)
        end
      end
      cells.to_a
    end

    # Convert a set of H3 cells to a GeoJSON::MultiPolygon geometry.
    #
    # @param [Array<UInt64>] h3_set An array of valid H3 indexes.
    #
    # @example Convert cells to a GeoJSON MultiPolygon.
    #   cells = H3.polygon_to_cells(polygon, 9)
    #   multi_polygon = H3.cells_to_geojson_multi_polygon(cells)
    #
    # @return [::GeoJSON::MultiPolygon] A GeoJSON MultiPolygon geometry.
    def cells_to_geojson_multi_polygon(h3_set : Array(UInt64)) : ::GeoJSON::MultiPolygon
      multi_polygon_data = H3.cells_to_multi_polygon(h3_set)

      polygon_coords = multi_polygon_data.map do |polygon_loops|
        polygon_loops.map do |loop_coords|
          ring = loop_coords.map do |lat, lng|
            # GeoJSON coordinates are [longitude, latitude]
            [lng, lat]
          end
          # GeoJSON requires closed rings (first == last position)
          if ring.size > 0 && ring.first != ring.last
            ring << ring.first.dup
          end
          ring
        end
      end

      ::GeoJSON::MultiPolygon.new(polygon_coords)
    end

    private def geojson_polygon_to_h3_coords(polygon : ::GeoJSON::Polygon) : Tuple(Array(Tuple(Float64, Float64)), Array(Array(Tuple(Float64, Float64))))
      geojson_rings_to_h3_coords(polygon.coordinates)
    end

    private def geojson_rings_to_h3_coords(rings : Array(Array(::GeoJSON::Coordinates))) : Tuple(Array(Tuple(Float64, Float64)), Array(Array(Tuple(Float64, Float64))))
      return {[] of Tuple(Float64, Float64), [] of Array(Tuple(Float64, Float64))} if rings.empty?

      # GeoJSON coordinates are [longitude, latitude]; H3 expects (latitude, longitude)
      outer = rings.first.map { |coord| {coord.latitude, coord.longitude} }
      holes = rings[1..].map { |ring| ring.map { |coord| {coord.latitude, coord.longitude} } }

      {outer, holes}
    end
  end

  extend GeoJSON
end
