require "./bindings/base"
require "./miscellaneous"

module Polygon
  include H3::Bindings::Base
  include Miscellaneous

  # Derive the maximum number of H3 cells that could fill a given polygon
  # at the specified resolution.
  #
  # @param [Array<Tuple(Float64, Float64)>] polygon Outer boundary coordinates (lat, lng) in degrees.
  # @param [Array<Array<Tuple(Float64, Float64)>>] holes Interior boundary (hole) coordinates in degrees.
  # @param [Integer] resolution The desired H3 resolution (0-15).
  # @param [Integer] flags Containment mode flags (default 0 = center containment).
  #
  # @example Get the max number of cells for a polygon.
  #   polygon = [{37.813318, -122.4089866}, {37.7866302, -122.3805436}, {37.7198061, -122.3544736}, {37.7076131, -122.5123436}]
  #   H3.max_polygon_to_cells_size(polygon, 9)
  #
  # @return [Integer] Maximum number of H3 cells.
  def max_polygon_to_cells_size(polygon : Array(Tuple(Float64, Float64)), resolution : Int32, holes : Array(Array(Tuple(Float64, Float64))) = [] of Array(Tuple(Float64, Float64)), flags : UInt32 = 0_u32) : Int64
    geo_polygon = build_geo_polygon(polygon, holes)
    count = 0_i64
    err = LibH3.max_polygon_to_cells_size(pointerof(geo_polygon), Resolution.new(resolution), flags, pointerof(count))
    raise Exception.new("Couldn't estimate max polygon to cells size") if err != 0

    count
  end

  # Fill a polygon with H3 cells at the specified resolution.
  #
  # @param [Array<Tuple(Float64, Float64)>] polygon Outer boundary coordinates (lat, lng) in degrees.
  # @param [Array<Array<Tuple(Float64, Float64)>>] holes Interior boundary (hole) coordinates in degrees.
  # @param [Integer] resolution The desired H3 resolution (0-15).
  # @param [Integer] flags Containment mode flags (default 0 = center containment).
  #
  # @example Fill a polygon with H3 cells.
  #   polygon = [{37.813318, -122.4089866}, {37.7866302, -122.3805436}, {37.7198061, -122.3544736}, {37.7076131, -122.5123436}]
  #   H3.polygon_to_cells(polygon, 9)
  #
  # @return [Array<Integer>] Array of H3 indexes filling the polygon.
  def polygon_to_cells(polygon : Array(Tuple(Float64, Float64)), resolution : Int32, holes : Array(Array(Tuple(Float64, Float64))) = [] of Array(Tuple(Float64, Float64)), flags : UInt32 = 0_u32) : Array(UInt64)
    geo_polygon = build_geo_polygon(polygon, holes)
    max_size = 0_i64
    err = LibH3.max_polygon_to_cells_size(pointerof(geo_polygon), Resolution.new(resolution), flags, pointerof(max_size))
    raise Exception.new("Couldn't estimate max polygon to cells size") if err != 0
    return [] of UInt64 if max_size <= 0

    output = Pointer(UInt64).malloc(max_size)
    err = LibH3.polygon_to_cells(pointerof(geo_polygon), Resolution.new(resolution), flags, output)
    raise Exception.new("Couldn't fill polygon with cells") if err != 0

    read_array_of_uint64(output, max_size)
  end

  # Convert a set of H3 cells to a linked multi-polygon structure.
  #
  # Returns an array of polygons, where each polygon is an array of loops,
  # and each loop is an array of coordinate pairs (lat, lng) in degrees.
  #
  # @param [Array<Integer>] h3_set An array of valid H3 indexes.
  #
  # @example Convert cells to polygon outlines.
  #   cells = [612933930963697663]
  #   H3.cells_to_multi_polygon(cells)
  #
  # @return [Array<Array<Array<Tuple(Float64, Float64)>>>] Array of polygons (each polygon is an array of loops, each loop is coordinates).
  def cells_to_multi_polygon(h3_set : Array(UInt64)) : Array(Array(Array(Tuple(Float64, Float64))))
    linked_polygon = LibH3::LinkedGeoPolygon.new(
      first: Pointer(LibH3::LinkedGeoLoop).null,
      last: Pointer(LibH3::LinkedGeoLoop).null,
      next: Pointer(LibH3::LinkedGeoPolygon).null
    )

    err = LibH3.cells_to_linked_multi_polygon(h3_set, h3_set.size.to_i32, pointerof(linked_polygon))
    raise Exception.new("Couldn't convert cells to multi polygon") if err != 0

    result = collect_linked_polygons(pointerof(linked_polygon))
    LibH3.destroy_linked_multi_polygon(pointerof(linked_polygon))

    result
  end

  private def build_geo_polygon(polygon : Array(Tuple(Float64, Float64)), holes : Array(Array(Tuple(Float64, Float64)))) : LibH3::GeoPolygon
    # Convert outer boundary to radians
    outer_verts = Pointer(LibH3::LatLng).malloc(polygon.size)
    polygon.each_with_index do |coord, i|
      outer_verts[i] = LibH3::LatLng.new(
        lat: degs_to_rads(coord[0]),
        lng: degs_to_rads(coord[1])
      )
    end

    outer_loop = LibH3::GeoLoop.new(
      num_verts: polygon.size.to_i32,
      verts: outer_verts
    )

    # Convert holes to radians
    if holes.empty?
      LibH3::GeoPolygon.new(
        geoloop: outer_loop,
        num_holes: 0,
        holes: Pointer(LibH3::GeoLoop).null
      )
    else
      hole_loops = Pointer(LibH3::GeoLoop).malloc(holes.size)
      holes.each_with_index do |hole, i|
        hole_verts = Pointer(LibH3::LatLng).malloc(hole.size)
        hole.each_with_index do |coord, j|
          hole_verts[j] = LibH3::LatLng.new(
            lat: degs_to_rads(coord[0]),
            lng: degs_to_rads(coord[1])
          )
        end
        hole_loops[i] = LibH3::GeoLoop.new(
          num_verts: hole.size.to_i32,
          verts: hole_verts
        )
      end

      LibH3::GeoPolygon.new(
        geoloop: outer_loop,
        num_holes: holes.size.to_i32,
        holes: hole_loops
      )
    end
  end

  private def collect_linked_polygons(polygon_ptr : Pointer(LibH3::LinkedGeoPolygon)) : Array(Array(Array(Tuple(Float64, Float64))))
    result = [] of Array(Array(Tuple(Float64, Float64)))
    current_polygon = polygon_ptr

    while !current_polygon.null?
      polygon_loops = [] of Array(Tuple(Float64, Float64))
      current_loop = current_polygon.value.first

      while !current_loop.null?
        coords = [] of Tuple(Float64, Float64)
        current_coord = current_loop.value.first

        while !current_coord.null?
          vertex = current_coord.value.vertex
          coords << {rads_to_degs(vertex.lat), rads_to_degs(vertex.lng)}
          current_coord = current_coord.value.next
        end

        polygon_loops << coords
        current_loop = current_loop.value.next
      end

      result << polygon_loops
      current_polygon = current_polygon.value.next
    end

    result
  end
end
