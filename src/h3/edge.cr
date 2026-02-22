require "./bindings/base"
require "./miscellaneous"

module Edge
  include H3::Bindings::Base
  include Miscellaneous

  # @!method are_neighbor_cells(origin, destination)
  #
  # Determine whether two H3 indexes are neighbors.
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] destination Destination H3 index.
  #
  # @example Check if two indexes are neighbors.
  #   H3.are_neighbor_cells(617700169983721471, 617700169982672895)
  #   true
  #
  # @return [Boolean] True if the indexes are neighbors.
  def are_neighbor_cells(origin : UInt64, destination : UInt64) : Bool
    result = 0_i32
    err = LibH3.are_neighbor_cells(origin, destination, pointerof(result))
    raise Exception.new("Couldn't determine if cells are neighbors") if err != 0
    result != 0
  end

  # @!method cells_to_directed_edge(origin, destination)
  #
  # Derive the directed edge H3 index for the given origin and destination pair.
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] destination Destination H3 index.
  #
  # @example Get the directed edge between two neighbors.
  #   H3.cells_to_directed_edge(617700169983721471, 617700169982672895)
  #   1608700169983721471
  #
  # @raise [Exception] If the cells are not neighbors.
  #
  # @return [Integer] H3 index of the directed edge.
  def cells_to_directed_edge(origin : UInt64, destination : UInt64) : UInt64
    edge = 0_u64
    err = LibH3.cells_to_directed_edge(origin, destination, pointerof(edge))
    raise Exception.new("Couldn't get directed edge for given cells") if err != 0
    edge
  end

  # @!method valid_directed_edge?(edge)
  #
  # Determine whether the given H3 index is a valid directed edge.
  #
  # @param [Integer] edge A H3 index.
  #
  # @example Check if the H3 index is a valid directed edge.
  #   H3.valid_directed_edge?(1608700169983721471)
  #   true
  #
  # @return [Boolean] True if the H3 index is a valid directed edge.
  def valid_directed_edge?(edge : UInt64) : Bool
    LibH3.is_valid_directed_edge(edge) != 0
  end

  # @!method directed_edge_origin(edge)
  #
  # Returns the origin cell from the given directed edge.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get the origin cell of a directed edge.
  #   H3.directed_edge_origin(1608700169983721471)
  #   617700169983721471
  #
  # @return [Integer] H3 index of the origin cell.
  def directed_edge_origin(edge : UInt64) : UInt64
    origin = 0_u64
    err = LibH3.get_directed_edge_origin(edge, pointerof(origin))
    raise Exception.new("Couldn't get origin for directed edge") if err != 0
    origin
  end

  # @!method directed_edge_destination(edge)
  #
  # Returns the destination cell from the given directed edge.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get the destination cell of a directed edge.
  #   H3.directed_edge_destination(1608700169983721471)
  #   617700169982672895
  #
  # @return [Integer] H3 index of the destination cell.
  def directed_edge_destination(edge : UInt64) : UInt64
    destination = 0_u64
    err = LibH3.get_directed_edge_destination(edge, pointerof(destination))
    raise Exception.new("Couldn't get destination for directed edge") if err != 0
    destination
  end

  # @!method directed_edge_to_cells(edge)
  #
  # Returns the origin and destination cells from the given directed edge.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get both cells of a directed edge.
  #   H3.directed_edge_to_cells(1608700169983721471)
  #   {617700169983721471, 617700169982672895}
  #
  # @return [Tuple(UInt64, UInt64)] Origin and destination H3 indexes.
  def directed_edge_to_cells(edge : UInt64) : Tuple(UInt64, UInt64)
    cells = Pointer(UInt64).malloc(2)
    err = LibH3.directed_edge_to_cells(edge, cells)
    raise Exception.new("Couldn't get cells for directed edge") if err != 0
    {cells[0], cells[1]}
  end

  # @!method origin_to_directed_edges(origin)
  #
  # Returns all directed edges originating from the given cell.
  #
  # @param [Integer] origin A valid H3 index.
  #
  # @example Get all directed edges from a cell.
  #   H3.origin_to_directed_edges(617700169983721471)
  #   [1608700169983721471, ...]
  #
  # @return [Array<Integer>] Array of directed edge H3 indexes (6 for hexagons, 5 for pentagons).
  def origin_to_directed_edges(origin : UInt64) : Array(UInt64)
    edges = Pointer(UInt64).malloc(6)
    err = LibH3.origin_to_directed_edges(origin, edges)
    raise Exception.new("Couldn't get directed edges for origin") if err != 0
    read_array_of_uint64(edges, 6)
  end

  # @!method directed_edge_to_boundary(edge)
  #
  # Returns the coordinates of the directed edge boundary.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get the boundary of a directed edge.
  #   H3.directed_edge_to_boundary(1608700169983721471)
  #   [{lat1, lng1}, {lat2, lng2}]
  #
  # @return [Array<Tuple(Float64, Float64)>] Array of coordinate pairs.
  def directed_edge_to_boundary(edge : UInt64) : Array(Tuple(Float64, Float64))
    geo_boundary = LibH3::CellBoundary.new(num_verts: 0, verts: StaticArray(LibH3::LatLng, 10).new(LibH3::LatLng.new(lat: 0.0, lng: 0.0)))
    err = LibH3.directed_edge_to_boundary(edge, pointerof(geo_boundary))
    raise Exception.new("Couldn't get boundary for directed edge") if err != 0

    geo_boundary.verts.first(geo_boundary.num_verts).map do |vertex|
      {rads_to_degs(vertex.lat), rads_to_degs(vertex.lng)}
    end
  end

  # @!method exact_edge_length_rads(edge)
  #
  # Returns the exact length of the given directed edge in radians.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get edge length in radians.
  #   H3.exact_edge_length_rads(1608700169983721471)
  #   0.001234
  #
  # @return [Float] Edge length in radians.
  def exact_edge_length_rads(edge : UInt64) : Float64
    length = 0.0
    err = LibH3.exact_edge_length_rads(edge, pointerof(length))
    raise Exception.new("Couldn't get edge length in radians") if err != 0
    length
  end

  # @!method exact_edge_length_km(edge)
  #
  # Returns the exact length of the given directed edge in kilometres.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get edge length in kilometres.
  #   H3.exact_edge_length_km(1608700169983721471)
  #   7.86
  #
  # @return [Float] Edge length in kilometres.
  def exact_edge_length_km(edge : UInt64) : Float64
    length = 0.0
    err = LibH3.exact_edge_length_km(edge, pointerof(length))
    raise Exception.new("Couldn't get edge length in kilometres") if err != 0
    length
  end

  # @!method exact_edge_length_m(edge)
  #
  # Returns the exact length of the given directed edge in metres.
  #
  # @param [Integer] edge A valid directed edge H3 index.
  #
  # @example Get edge length in metres.
  #   H3.exact_edge_length_m(1608700169983721471)
  #   7860.0
  #
  # @return [Float] Edge length in metres.
  def exact_edge_length_m(edge : UInt64) : Float64
    length = 0.0
    err = LibH3.exact_edge_length_m(edge, pointerof(length))
    raise Exception.new("Couldn't get edge length in metres") if err != 0
    length
  end
end
