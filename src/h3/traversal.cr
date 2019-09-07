require "./bindings/base"

module Traversal
  include H3::Bindings::Base
  include Miscellaneous

  # @!method max_kring_size(k)
  #
  # Derive the maximum k-ring size for distance k.
  #
  # @param [Integer] k K value.
  #
  # @example Derive the maximum k-ring size for k=5
  #   H3.max_kring_size(5)
  #   91
  #
  # @return [Integer] Maximum k-ring size.
  def max_kring_size(k : Int32) : Int32
    LibH3.max_kring_size(k)
  end

  # @!method distance(origin, h3_index)
  #
  # Derive the distance between two H3 indexes.
  #
  # @param [Integer] origin Origin H3 index
  # @param [Integer] h3_index H3 index
  #
  # @example Derive the distance between two H3 indexes.
  #   H3.distance(617700169983721471, 617700169959866367)
  #   5
  #
  # @return [Integer] Distance between indexes.
  def distance(origin : UInt64, h3_index : UInt64) : Int32
    LibH3.distance(origin, h3_index)
  end

  # @!method line_size(origin, destination)
  #
  # Derive the number of hexagons present in a line between two H3 indexes.
  #
  # This value is simply `h3_distance(origin, destination) + 1` when a line is computable.
  #
  # Returns a negative number if a line cannot be computed e.g.
  # a pentagon was encountered, or the hexagons are too far apart.
  #
  # @param [Integer] origin Origin H3 index
  # @param [Integer] destination H3 index
  #
  # @example Derive the number of hexagons present in a line between two H3 indexes.
  #   H3.line_size(617700169983721471, 617700169959866367)
  #   6
  #
  # @return [Integer] Number of hexagons found between indexes.
  def line_size(origin : UInt64, destination : UInt64) : Int32
    LibH3.line_size(origin, destination)
  end

  # Derives H3 indexes within k distance of the origin H3 index.
  #
  # Similar to {k_ring}, except that an error is raised when one of the indexes
  # returned is a pentagon or is in the pentagon distortion area.
  #
  # k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0
  # and all neighboring indexes, and so on.
  #
  # Output is inserted into the array in order of increasing distance from the origin.
  #
  # @param [Integer] origin Origin H3 index
  # @param [Integer] k K distance.
  #
  # @example Derive the hex range for a given H3 index with k of 0.
  #   H3.hex_range(617700169983721471, 0)
  #   [617700169983721471]
  #
  # @example Derive the hex range for a given H3 index with k of 1.
  #   H3.hex_range(617700169983721471, 1)
  #   [
  #     617700169983721471, 617700170047946751, 617700169984245759,
  #     617700169982672895, 617700169983983615, 617700170044276735,
  #     617700170044014591
  #   ]
  #
  # @raise [ArgumentError] Raised if the range contains a pentagon.
  #
  # @return [Array<Integer>] Array of H3 indexes within the k-range.
  def hex_range(origin, k) : Array(UInt64)
    max_hexagons = max_kring_size(k)
    output = Pointer(UInt64).malloc(max_hexagons)
    pentagonal_distortion = LibH3.hex_range(origin, k, output)
    raise(Exception.new("Specified hexagon range contains a pentagon")) if pentagonal_distortion

    read_array_of_uint64(output, max_hexagons)
  end

  # Derives H3 indexes within k distance of the origin H3 index.
  #
  # k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0
  # and all neighboring indexes, and so on.
  #
  # @param [Integer] origin Origin H3 index
  # @param [Integer] k K distance.
  #
  # @example Derive the k-ring for a given H3 index with k of 0.
  #   H3.k_ring(617700169983721471, 0)
  #   [617700169983721471]
  #
  # @example Derive the k-ring for a given H3 index with k of 1.
  #   H3.k_ring(617700169983721471, 1)
  #   [
  #     617700169983721471, 617700170047946751, 617700169984245759,
  #     617700169982672895, 617700169983983615, 617700170044276735,
  #     617700170044014591
  #   ]
  #
  # @return [Array<Integer>] Array of H3 indexes within the k-range.
  def k_ring(origin, k) : Array(UInt64)
    max_hexagons = max_kring_size(k)
    output = Pointer(UInt64).malloc(max_hexagons)
    LibH3.k_ring(origin, k, output)

    read_array_of_uint64(output, max_hexagons)
  end

  # Derives the hollow hexagonal ring centered at origin with sides of length k.
  #
  # An error is raised when one of the indexes returned is a pentagon or is
  # in the pentagon distortion area.
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] k K distance.
  #
  # @example Derive the hex ring for the H3 index at k = 1
  #   H3.hex_ring(617700169983721471, 1)
  #   [
  #     617700170044014591, 617700170047946751, 617700169984245759,
  #     617700169982672895, 617700169983983615, 617700170044276735
  #   ]
  #
  # @raise [ArgumentError] Raised if the hex ring contains a pentagon.
  #
  # @return [Array<Integer>] Array of H3 indexes within the hex ring.
  def hex_ring(origin, k) : Array(UInt64)
    max_hexagons = max_hex_ring_size(k)
    output = Pointer(UInt64).malloc(max_hexagons)
    pentagonal_distortion = LibH3.hex_ring(origin, k, output)
    raise Exception.new("The hex ring contains a pentagon") if pentagonal_distortion

    read_array_of_uint64(output, max_hexagons)
  end

  # Derive the maximum hex ring size for a given distance k.
  #
  # NOTE: This method is not part of the H3 API and is added to this binding for convenience.
  #
  # @param [Integer] k K distance.
  #
  # @example Derive maximum hex ring size for k distance 6.
  #   H3.max_hex_ring_size(6)
  #   36
  #
  # @return [Integer] Maximum hex ring size.
  def max_hex_ring_size(k : Int32) : Int32
    k.zero? ? 1 : 6 * k
  end

  # Derives H3 indexes within k distance for each H3 index in the set.
  #
  # @param [Array<Integer>] h3_set Set of H3 indexes
  # @param [Integer] k K distance.
  #
  # @example Derive the hex ranges for a given H3 set with k of 0.
  #   H3.hex_ranges([617700169983721471, 617700169982672895], 1)
  #   {
  #     617700169983721471 => [
  #       [617700169983721471],
  #       [
  #         617700170047946751, 617700169984245759, 617700169982672895,
  #         617700169983983615, 617700170044276735, 617700170044014591
  #       ]
  #     ],
  #     617700169982672895 = > [
  #       [617700169982672895],
  #       [
  #         617700169984245759, 617700169983197183, 617700169983459327,
  #         617700169982935039, 617700169983983615, 617700169983721471
  #       ]
  #     ]
  #   }
  #
  # @raise [ArgumentError] Raised if any of the ranges contains a pentagon.
  #
  # @see #hex_range
  #
  # @return [Hash] Hash of H3 index keys, with array values grouped by k-ring.
  def hex_ranges_grouped(h3_set, k) : Hash(UInt64, Array(Array(UInt64)))
    h3_range_indexes = hex_ranges_ungrouped(h3_set, k)

    h3_range_indexes.each_slice(max_kring_size(k)).each_with_object({} of UInt64 => Array(Array(UInt64))) do |indexes, output|
      h3_index = indexes.first

      output[h3_index] = k_rings_for_hex_range(indexes, k)
    end
  end

  # Derives H3 indexes within k distance for each H3 index in the set.
  #
  # @param [Array<Integer>] h3_set Set of H3 indexes
  # @param [Integer] k K distance.
  # @example Derive the hex ranges for a given H3 set with k of 0 ungrouped.
  #   H3.hex_ranges([617700169983721471, 617700169982672895], 1, grouped: false)
  #   [
  #     617700169983721471, 617700170047946751, 617700169984245759,
  #     617700169982672895, 617700169983983615, 617700170044276735,
  #     617700170044014591, 617700169982672895, 617700169984245759,
  #     617700169983197183, 617700169983459327, 617700169982935039,
  #     617700169983983615, 617700169983721471
  #   ]
  #
  # @raise [ArgumentError] Raised if any of the ranges contains a pentagon.
  def hex_ranges_ungrouped(h3_set : Array(UInt64), k : Int32) : Array(UInt64)
    max_out_size = h3_set.size * max_kring_size(k)
    output = Pointer(UInt64).malloc(max_out_size)

    if LibH3.hex_ranges(h3_set, h3_set.size, k, output)
      raise Exception.new("One of the specified hexagon ranges contains a pentagon")
    end

    read_array_of_uint64(output, max_out_size)
  end

  # Derives the hex range for the given origin at k distance, sub-grouped by distance.
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] k K distance.
  #
  # @example Derive hex range at distance 2
  #   H3.hex_range_distances(617700169983721471, 2)
  #   {
  #     0 => [617700169983721471],
  #     1 = >[
  #       617700170047946751, 617700169984245759, 617700169982672895,
  #       617700169983983615, 617700170044276735, 617700170044014591
  #     ],
  #     2 => [
  #       617700170048995327, 617700170047684607, 617700170048471039,
  #       617700169988177919, 617700169983197183, 617700169983459327,
  #       617700169982935039, 617700175096053759, 617700175097102335,
  #       617700170043752447, 617700170043490303, 617700170045063167
  #     ]
  #   }
  #
  # @raise [ArgumentError] Raised when the hex range contains a pentagon.
  #
  # @return [Hash] Hex range grouped by distance.
  def hex_range_distances(origin, k) : Hash(Int32, Array(UInt64))
    max_out_size = max_kring_size(k)
    output = Pointer(UInt64).malloc(max_out_size)
    distances = Pointer(Int32).malloc(max_out_size)
    pentagonal_distortion = LibH3.hex_range_distances(origin, k, output, distances)
    raise(Exception.new("Specified hexagon range contains a pentagon")) if pentagonal_distortion

    hexagons = read_array_of_uint64(output, max_out_size)
    distances = read_array_of_int32(distances, max_out_size)
    output = Hash(Int32, Array(UInt64)).new

    distances.zip(hexagons).group_by { |dist| dist.first }
      .map do |dist, array_of_tuples|
        output[dist] = array_of_tuples.map { |tuple| tuple.last }
      end

    output
  end

  # Derives the k-ring for the given origin at k distance, sub-grouped by distance.
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] k K distance.
  #
  # @example Derive k-ring at distance 2
  #   H3.k_ring_distances(617700169983721471, 2)
  #   {
  #     0 => [617700169983721471],
  #     1 = >[
  #       617700170047946751, 617700169984245759, 617700169982672895,
  #       617700169983983615, 617700170044276735, 617700170044014591
  #     ],
  #     2 => [
  #       617700170048995327, 617700170047684607, 617700170048471039,
  #       617700169988177919, 617700169983197183, 617700169983459327,
  #       617700169982935039, 617700175096053759, 617700175097102335,
  #       617700170043752447, 617700170043490303, 617700170045063167
  #     ]
  #   }
  #
  # @return [Hash] Hash of k-ring distances grouped by distance.
  def k_ring_distances(origin, k) : Hash(Int32, Array(UInt64))
    max_out_size = max_kring_size(k)
    output = Pointer(UInt64).malloc(max_out_size)
    distances = Pointer(Int32).malloc(max_out_size)
    LibH3.k_ring_distances(origin, k, output, distances)
    hexagons = read_array_of_uint64(output, max_out_size)
    distances = read_array_of_int32(distances, max_out_size)

    output = Hash(Int32, Array(UInt64)).new

    distances.zip(hexagons).group_by { |dist| dist.first }
      .map do |dist, array_of_tuples|
        output[dist] = array_of_tuples.map { |tuple| tuple.last }
      end

    output
  end

  # Derives the H3 indexes found in a line between an origin H3 index
  # and a destination H3 index (inclusive of origin and destination).
  #
  # @param [Integer] origin Origin H3 index.
  # @param [Integer] destination Destination H3 index.
  #
  # @example Derive the indexes found in a line.
  #   H3.line(617700169983721471, 617700169959866367)
  #   [
  #     617700169983721471, 617700169984245759, 617700169988177919,
  #     617700169986867199, 617700169987391487, 617700169959866367
  #   ]
  #
  # @raise [ArgumentError] Could not compute line
  #
  # @return [Array<Integer>] H3 indexes
  def line(origin, destination)
    max_hexagons = line_size(origin, destination)
    hexagons = Pointer(UInt64).malloc(max_hexagons)
    res = LibH3.h3_line(origin, destination, hexagons)
    raise Exception.new("Could not compute line") if res.sign == -1

    read_array_of_uint64(hexagons, max_hexagons)
  end

  private def k_rings_for_hex_range(indexes, k)
    (0..k).map do |j|
      start = j.zero? ? 0 : max_kring_size(j - 1)
      length = max_hex_ring_size(j)
      indexes[start, length]
    end
  end
end
