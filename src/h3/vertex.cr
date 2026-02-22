require "./bindings/base"
require "./miscellaneous"

module Vertex
  include H3::Bindings::Base
  include Miscellaneous

  # Returns the vertex index for the given cell and vertex number.
  #
  # @param [Integer] origin A valid H3 cell index.
  # @param [Integer] vertex_num The vertex number (0-5 for hexagons, 0-4 for pentagons).
  #
  # @example Get vertex 0 of a cell.
  #   H3.cell_to_vertex(612933930963697663, 0)
  #
  # @raise [Exception] If the vertex number is invalid for the cell.
  #
  # @return [Integer] H3 vertex index.
  def cell_to_vertex(origin : UInt64, vertex_num : Int32) : UInt64
    vertex = 0_u64
    err = LibH3.cell_to_vertex(origin, vertex_num, pointerof(vertex))
    raise Exception.new("Couldn't get vertex for cell") if err != 0
    vertex
  end

  # Returns all vertex indexes for the given cell.
  #
  # Hexagonal cells have 6 vertices. Pentagonal cells have 5 vertices.
  # The output array is allocated with 6 elements; for pentagons, one
  # element will be zero and is filtered out.
  #
  # @param [Integer] origin A valid H3 cell index.
  #
  # @example Get all vertices of a cell.
  #   H3.cell_to_vertexes(612933930963697663)
  #
  # @raise [Exception] If the operation fails.
  #
  # @return [Array<Integer>] Array of H3 vertex indexes.
  def cell_to_vertexes(origin : UInt64) : Array(UInt64)
    vertexes = Pointer(UInt64).malloc(6)
    err = LibH3.cell_to_vertexes(origin, vertexes)
    raise Exception.new("Couldn't get vertexes for cell") if err != 0
    read_array_of_uint64(vertexes, 6)
  end

  # Returns the latitude and longitude of the given vertex in degrees.
  #
  # @param [Integer] vertex A valid H3 vertex index.
  #
  # @example Get the coordinates of a vertex.
  #   H3.vertex_to_lat_lng(vertex_index)
  #   {lat, lng}
  #
  # @raise [Exception] If the vertex is invalid.
  #
  # @return [Tuple(Float64, Float64)] Latitude and longitude in degrees.
  def vertex_to_lat_lng(vertex : UInt64) : Tuple(Float64, Float64)
    coords = LibH3::LatLng.new(lat: 0.0, lng: 0.0)
    err = LibH3.vertex_to_lat_lng(vertex, pointerof(coords))
    raise Exception.new("Couldn't get coordinates for vertex") if err != 0
    {rads_to_degs(coords.lat), rads_to_degs(coords.lng)}
  end

  # Determines whether the given H3 index is a valid vertex.
  #
  # @param [Integer] vertex A H3 index.
  #
  # @example Check if an index is a valid vertex.
  #   H3.valid_vertex?(vertex_index)
  #   true
  #
  # @return [Boolean] True if the H3 index is a valid vertex.
  def valid_vertex?(vertex : UInt64) : Bool
    LibH3.is_valid_vertex(vertex) != 0
  end

  # Converts an H3 cell index to local IJ coordinates relative to an origin cell.
  #
  # The mode parameter controls the coordinate system behavior. Use 0 for default.
  #
  # @param [Integer] origin Origin H3 cell index.
  # @param [Integer] h3 Target H3 cell index.
  # @param [Integer] mode Coordinate system mode (default 0).
  #
  # @example Convert cell to local IJ coordinates.
  #   H3.cell_to_local_ij(origin, target)
  #   {i, j}
  #
  # @raise [Exception] If the conversion fails (e.g., cells are too far apart or a pentagon is encountered).
  #
  # @return [Tuple(Int32, Int32)] IJ coordinates as {i, j}.
  def cell_to_local_ij(origin : UInt64, h3 : UInt64, mode : UInt32 = 0_u32) : Tuple(Int32, Int32)
    coord = LibH3::CoordIJ.new(i: 0, j: 0)
    err = LibH3.cell_to_local_ij(origin, h3, mode, pointerof(coord))
    raise Exception.new("Couldn't convert cell to local IJ coordinates") if err != 0
    {coord.i, coord.j}
  end

  # Converts local IJ coordinates to an H3 cell index relative to an origin cell.
  #
  # The mode parameter controls the coordinate system behavior. Use 0 for default.
  #
  # @param [Integer] origin Origin H3 cell index.
  # @param [Tuple(Int32, Int32)] ij IJ coordinates as {i, j}.
  # @param [Integer] mode Coordinate system mode (default 0).
  #
  # @example Convert local IJ coordinates back to a cell.
  #   H3.local_ij_to_cell(origin, {1, 2})
  #
  # @raise [Exception] If the conversion fails.
  #
  # @return [Integer] H3 cell index.
  def local_ij_to_cell(origin : UInt64, ij : Tuple(Int32, Int32), mode : UInt32 = 0_u32) : UInt64
    coord = LibH3::CoordIJ.new(i: ij[0], j: ij[1])
    result = 0_u64
    err = LibH3.local_ij_to_cell(origin, pointerof(coord), mode, pointerof(result))
    raise Exception.new("Couldn't convert local IJ coordinates to cell") if err != 0
    result
  end
end
