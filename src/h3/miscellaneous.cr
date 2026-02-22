require "./bindings/base"

module Miscellaneous
  include H3::Bindings::Base

  # @!method degs_to_rads(degs)
  #
  # Convert a number expressed in degrees to its equivalent in radians.
  #
  # @param [Float] degs Value expressed in degrees.
  #
  # @example Convert degrees value to radians.
  #   H3.degs_to_rads(19.61922082086965)
  #   0.34242
  #
  # @return [Float] Value expressed in radians.
  def degs_to_rads(degrees : Float64) : Float64
    LibH3.degs_to_rads(degrees)
  end

  # @!method edge_length_km(resolution)
  #
  # Derive the length of a hexagon edge in kilometres at the given resolution.
  #
  # @param [Integer] resolution Resolution.
  #
  # @example Derive length of edge in kilometres
  #   H3.edge_length_km(3)
  #   59.81085794
  #
  # @return [Float] Length of edge in kilometres
  def edge_length_km(resolution : Int32) : Float64
    length = 0.0
    LibH3.edge_length_km(Resolution.new(resolution), pointerof(length))
    length
  end

  # @!method edge_length_m(resolution)
  #
  # Derive the length of a hexagon edge in metres at the given resolution.
  #
  # @param [Integer] resolution Resolution.
  #
  # @example Derive length of edge in metres
  #   H3.edge_length_m(6)
  #   3229.482772
  #
  # @return [Float] Length of edge in metres
  def edge_length_m(resolution : Int32) : Float64
    length = 0.0
    LibH3.edge_length_m(Resolution.new(resolution), pointerof(length))
    length
  end

  # @!method hex_area_km2(resolution)
  #
  # Average hexagon area in square kilometres at the given resolution.
  #
  # @param [Integer] resolution Resolution.
  #
  # @example Find the square kilometre size at resolution 5
  #   H3.hex_area_km2(5)
  #   252.9033645
  #
  # @return [Float] Average hexagon area in square kilometres.
  def hex_area_km2(resolution : Int32) : Float64
    area = 0.0
    LibH3.hex_area_km2(Resolution.new(resolution), pointerof(area))
    area
  end

  # @!method hex_area_m2(resolution)
  #
  # Average hexagon area in square metres at the given resolution.
  #
  # @param [Integer] resolution Resolution.
  #
  # @example Find the square metre size at resolution 10
  #   H3.hex_area_m2(10)
  #   15047.5
  #
  # @return [Float] Average hexagon area in square metres.
  def hex_area_m2(resolution : Int32) : Float64
    area = 0.0
    LibH3.hex_area_m2(Resolution.new(resolution), pointerof(area))
    area
  end

  # @!method hexagon_count(resolution)
  #
  # Number of unique H3 indexes at the given resolution.
  #
  # @param [Integer] resolution Resolution.
  #
  # @example Find number of hexagons at resolution 6
  #   H3.hexagon_count(6)
  #   14117882
  #
  # @return [Integer] Number of unique hexagons
  def hexagon_count(resolution : Int32) : Int64
    count = 0_i64
    LibH3.hexagon_count(Resolution.new(resolution), pointerof(count))
    count
  end

  # @!method rads_to_degs(rads)
  #
  # Convert a number expressed in radians to its equivalent in degrees.
  #
  # @param [Float] rads Value expressed in radians.
  #
  # @example Convert radians value to degrees.
  #   H3.rads_to_degs(0.34242)
  #   19.61922082086965
  #
  # @return [Float] Value expressed in degrees.
  def rads_to_degs(rads : Float64) : Float64
    LibH3.rads_to_degs(rads)
  end

  # @!method base_cell_count
  #
  # Returns the number of resolution 0 hexagons (base cells).
  #
  # @example Return the number of base cells
  #    H3.base_cell_count
  #    122
  #
  # @return [Integer] The number of resolution 0 hexagons (base cells).
  def base_cell_count : Int32
    LibH3.base_cell_count
  end

  # @!method pentagon_count
  #
  # Number of pentagon H3 indexes per resolution.
  # This is always 12, but provided as a convenience.
  #
  # @example Return the number of pentagons
  #    H3.pentagon_count
  #    12
  #
  # @return [Integer] The number of pentagons per resolution.
  def pentagon_count
    12
  end

  # Returns all resolution 0 hexagons (base cells).
  #
  # @example Return all base cells.
  #   H3.base_cells
  #   [576495936675512319, 576531121047601151, ..., 580753245698260991]
  #
  # @return [Array<Integer>] All resolution 0 hexagons (base cells).
  def base_cells : Array(UInt64)
    count = base_cell_count
    output = Pointer(UInt64).malloc(count)
    LibH3.res_0_cells(output)
    Array(UInt64).new(count) { |i| output[i] }
  end

  # @!method describe_h3_error(err)
  #
  # Provide a human-readable description of an H3Error error code.
  #
  # @param [Integer] err H3 error code.
  #
  # @example Describe error code 1
  #   H3.describe_h3_error(1)
  #   "The operation failed but a more specific error is not available"
  #
  # @return [String] Human-readable error description.
  def describe_h3_error(err : UInt32) : String
    String.new(LibH3.describe_h3_error(err))
  end

  # @!method valid_index?(h3_index)
  #
  # Determine whether the given H3 index is valid.
  # Unlike valid? (isValidCell), this validates any H3 index type
  # including cells, directed edges, and vertices.
  #
  # @param [Integer] h3_index A H3 index.
  #
  # @example Check if H3 index is valid
  #   H3.valid_index?(612933930963697663)
  #   true
  #
  # @return [Boolean] True if the H3 index is valid.
  def valid_index?(h3_index : UInt64) : Bool
    LibH3.is_valid_index(h3_index) != 0
  end

  # @!method get_index_digit(h3_index, resolution)
  #
  # Returns the index digit at the given resolution.
  # Resolution starts at 1 and goes up to 15.
  # The digit represents the direction from the parent cell at that resolution.
  #
  # @param [Integer] h3_index A valid H3 index.
  # @param [Integer] resolution Resolution level (1-15).
  #
  # @example Get the index digit at resolution 8
  #   H3.get_index_digit(612933930963697663, 8)
  #   0
  #
  # @return [Integer] The index digit at the given resolution.
  def get_index_digit(h3_index : UInt64, resolution : Int32) : Int32
    digit = 0_i32
    err = LibH3.get_index_digit(h3_index, resolution, pointerof(digit))
    raise Exception.new("Failed to get index digit") if err != 0
    digit
  end

  # Returns all pentagon indexes at the given resolution.
  #
  # @example Return all pentagons at resolution 4.
  #   H3.pentagons(4)
  #   [594615896891195391, 594967740612083711, ..., 598591730937233407]
  #
  # @return [Array<Integer>] All pentagon indexes at the given resolution.
  def pentagons(resolution) : Array(UInt64)
    count = 12
    output = Pointer(UInt64).malloc(count)
    LibH3.get_pentagons(resolution, output)
    Array(UInt64).new(count) { |i| output[i] }
  end

  # @!method cell_area_rads2(h3_index)
  #
  # Exact area of a specific cell in square radians.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Get exact area in square radians.
  #   H3.cell_area_rads2(612933930963697663)
  #   1.234e-10
  #
  # @return [Float] Exact area of the cell in square radians.
  def cell_area_rads2(h3_index : UInt64) : Float64
    area = 0.0
    err = LibH3.cell_area_rads2(h3_index, pointerof(area))
    raise Exception.new("Couldn't get cell area in square radians") if err != 0
    area
  end

  # @!method cell_area_km2(h3_index)
  #
  # Exact area of a specific cell in square kilometres.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Get exact area in square kilometres.
  #   H3.cell_area_km2(612933930963697663)
  #   0.1234
  #
  # @return [Float] Exact area of the cell in square kilometres.
  def cell_area_km2(h3_index : UInt64) : Float64
    area = 0.0
    err = LibH3.cell_area_km2(h3_index, pointerof(area))
    raise Exception.new("Couldn't get cell area in square kilometres") if err != 0
    area
  end

  # @!method cell_area_m2(h3_index)
  #
  # Exact area of a specific cell in square metres.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Get exact area in square metres.
  #   H3.cell_area_m2(612933930963697663)
  #   123400.0
  #
  # @return [Float] Exact area of the cell in square metres.
  def cell_area_m2(h3_index : UInt64) : Float64
    area = 0.0
    err = LibH3.cell_area_m2(h3_index, pointerof(area))
    raise Exception.new("Couldn't get cell area in square metres") if err != 0
    area
  end

  # @!method great_circle_distance_rads(lat1, lng1, lat2, lng2)
  #
  # Compute the great circle distance in radians between two points.
  # Coordinates are provided in degrees and converted to radians internally.
  #
  # @param [Float] lat1 Latitude of the first point in degrees.
  # @param [Float] lng1 Longitude of the first point in degrees.
  # @param [Float] lat2 Latitude of the second point in degrees.
  # @param [Float] lng2 Longitude of the second point in degrees.
  #
  # @example Compute great circle distance in radians.
  #   H3.great_circle_distance_rads(0.0, 0.0, 1.0, 0.0)
  #   0.01745
  #
  # @return [Float] Great circle distance in radians.
  def great_circle_distance_rads(lat1 : Float64, lng1 : Float64, lat2 : Float64, lng2 : Float64) : Float64
    a = LibH3::LatLng.new(lat: degs_to_rads(lat1), lng: degs_to_rads(lng1))
    b = LibH3::LatLng.new(lat: degs_to_rads(lat2), lng: degs_to_rads(lng2))
    LibH3.great_circle_distance_rads(pointerof(a), pointerof(b))
  end

  # @!method great_circle_distance_km(lat1, lng1, lat2, lng2)
  #
  # Compute the great circle distance in kilometres between two points.
  # Coordinates are provided in degrees and converted to radians internally.
  #
  # @param [Float] lat1 Latitude of the first point in degrees.
  # @param [Float] lng1 Longitude of the first point in degrees.
  # @param [Float] lat2 Latitude of the second point in degrees.
  # @param [Float] lng2 Longitude of the second point in degrees.
  #
  # @example Compute great circle distance in kilometres.
  #   H3.great_circle_distance_km(0.0, 0.0, 1.0, 0.0)
  #   111.195
  #
  # @return [Float] Great circle distance in kilometres.
  def great_circle_distance_km(lat1 : Float64, lng1 : Float64, lat2 : Float64, lng2 : Float64) : Float64
    a = LibH3::LatLng.new(lat: degs_to_rads(lat1), lng: degs_to_rads(lng1))
    b = LibH3::LatLng.new(lat: degs_to_rads(lat2), lng: degs_to_rads(lng2))
    LibH3.great_circle_distance_km(pointerof(a), pointerof(b))
  end

  # @!method great_circle_distance_m(lat1, lng1, lat2, lng2)
  #
  # Compute the great circle distance in metres between two points.
  # Coordinates are provided in degrees and converted to radians internally.
  #
  # @param [Float] lat1 Latitude of the first point in degrees.
  # @param [Float] lng1 Longitude of the first point in degrees.
  # @param [Float] lat2 Latitude of the second point in degrees.
  # @param [Float] lng2 Longitude of the second point in degrees.
  #
  # @example Compute great circle distance in metres.
  #   H3.great_circle_distance_m(0.0, 0.0, 1.0, 0.0)
  #   111195.0
  #
  # @return [Float] Great circle distance in metres.
  def great_circle_distance_m(lat1 : Float64, lng1 : Float64, lat2 : Float64, lng2 : Float64) : Float64
    a = LibH3::LatLng.new(lat: degs_to_rads(lat1), lng: degs_to_rads(lng1))
    b = LibH3::LatLng.new(lat: degs_to_rads(lat2), lng: degs_to_rads(lng2))
    LibH3.great_circle_distance_m(pointerof(a), pointerof(b))
  end
end
