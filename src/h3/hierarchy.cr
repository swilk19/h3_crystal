require "./bindings/base"
require "./miscellaneous"

module Hierarchy
  include H3::Bindings::Base
  include Miscellaneous

  # @!method parent(h3_index, parent_resolution)
  #
  # Derive the parent hexagon which contains the hexagon at the given H3 index.
  #
  # @param [Integer] h3_index A valid H3 index.
  # @param [Integer] parent_resoluton The desired resolution of the parent hexagon.
  #
  # @example Find the parent hexagon for a H3 index.
  #   H3.parent(613196570357137407, 6)
  #   604189371209351167
  #
  # @return [Integer] H3 index of parent hexagon.
  def parent(h3_index : UInt64, parent_resolution : Int32) : UInt64
    LibH3.parent(h3_index, Resolution.new(parent_resolution))
  end

  # @!method max_children(h3_index, child_resolution)
  #
  # Derive maximum number of child hexagons possible at given resolution.
  #
  # @param [Integer] h3_index A valid H3 index.
  # @param [Integer] child_resoluton The desired resolution of the child hexagons.
  #
  # @example Derive maximum number of child hexagons.
  #    H3.max_children(613196570357137407, 10)
  #    49
  #
  # @return [Integer] Maximum number of child hexagons possible at given resolution.
  def max_children(h3_index : UInt64, child_resolution : Int32) : Int32
    LibH3.max_children(h3_index, child_resolution)
  end

  # @!method center_child(h3_index, child_resolution)
  #
  # Returns the center child (finer) index contained by the given index
  # at the given resolution.
  #
  # @param [Integer] h3_index A valid H3 index.
  # @param [Integer] child_resoluton The desired resolution of the center child hexagon.
  #
  # @example Find center child hexagon.
  #    H3.center_child(613196570357137407, 10)
  #    622203769609814015
  #
  # @return [Integer] H3 index of center child hexagon.
  def center_child(h3_index : UInt64, resolution : Int32) : UInt64
    LibH3.center_child(h3_index, Resolution.new(resolution))
  end

  # Derive child hexagons contained within the hexagon at the given H3 index.
  #
  # @param [Integer] h3_index A valid H3 index.
  # @param [Integer] child_resolution The desired resolution of hexagons returned.
  #
  # @example Find the child hexagons for a H3 index.
  #   H3.children(613196570357137407, 9)
  #   [
  #     617700169982672895, 617700169982935039, 617700169983197183, 617700169983459327,
  #     617700169983721471, 617700169983983615, 617700169984245759
  #   ]
  #
  # @return [Array<Integer>] H3 indexes of child hexagons.
  def children(h3_index : UInt64, child_resolution : Int32) : Array(UInt64)
    max_children = max_children(h3_index, child_resolution)
    output = Pointer(UInt64).malloc(max_children)
    LibH3.h3_to_children(h3_index, Resolution.new(child_resolution), output)

    read_array_of_uint64(output, max_children)
  end

  # Find the maximum uncompacted size of the given set of H3 indexes.
  #
  # @param [Array<Integer>] compacted_set An array of valid H3 indexes.
  # @param [Integer] resolution The desired resolution to uncompact to.
  #
  # @example Find the maximum uncompacted size of the given set.
  #   h3_set = [
  #     617700440093229055, 617700440092704767, 617700440100569087, 617700440013012991,
  #     617700440013275135, 617700440092180479, 617700440091656191, 617700440092966911,
  #     617700440100831231, 617700440100044799, 617700440101617663, 617700440081956863,
  #     613196840447246335
  #   ]
  #   H3.max_uncompact_size(h3_set, 10)
  #   133
  #
  # @raise [ArgumentError] Given resolution is invalid for h3_set.
  #
  # @return [Integer] Maximum size of uncompacted set.
  def max_uncompact_size(compacted_set : Array(UInt64), resolution : Int32) : Int32
    size = LibH3.max_uncompact_size(compacted_set, compacted_set.size, Resolution.new(resolution))
    raise Exception.new("Couldn't estimate size. Invalid resolution?") if size.sign == -1

    size
  end

  # Compact a set of H3 indexes as best as possible.
  #
  # In the case where the set cannot be compacted, the set is returned unchanged.
  #
  # @param [Array<Integer>] h3_set An array of valid H3 indexes.
  #
  # @example Compact the given set.
  #   h3_set = [
  #     617700440073043967, 617700440072781823, 617700440073568255, 617700440093229055,
  #     617700440092704767, 617700440100569087, 617700440074092543, 617700440073830399,
  #     617700440074354687, 617700440073306111, 617700440013012991, 617700440013275135,
  #     617700440092180479, 617700440091656191, 617700440092966911, 617700440100831231,
  #     617700440100044799, 617700440101617663, 617700440081956863
  #   ]
  #   H3.compact(h3_set)
  #   [
  #     617700440093229055, 617700440092704767, 617700440100569087, 617700440013012991,
  #     617700440013275135, 617700440092180479, 617700440091656191, 617700440092966911,
  #     617700440100831231, 617700440100044799, 617700440101617663, 617700440081956863,
  #     613196840447246335
  #   ]
  #
  # @raise [RuntimeError] Couldn't attempt to compact given H3 indexes.
  #
  # @return [Array<Integer>] Compacted set of H3 indexes.
  def compact(h3_set : Array(UInt64)) : Array(UInt64)
    output = Pointer(UInt64).malloc(h3_set.size)
    failure = LibH3.compact(h3_set, output, h3_set.size)

    raise Exception.new("Couldn't compact given indexes") if failure
    read_array_of_uint64(output, h3_set.size)
  end

  # Uncompact a set of H3 indexes to the given resolution.
  #
  # @param [Array<Integer>] compacted_set An array of valid H3 indexes.
  # @param [Integer] resolution The desired resolution to uncompact to.
  #
  # @example Compact the given set.
  #   h3_set = [
  #     617700440093229055, 617700440092704767, 617700440100569087, 617700440013012991,
  #     617700440013275135, 617700440092180479, 617700440091656191, 617700440092966911,
  #     617700440100831231, 617700440100044799, 617700440101617663, 617700440081956863,
  #     613196840447246335
  #   ]
  #   H3.uncompact(h3_set)
  #   [
  #     617700440093229055, 617700440092704767, 617700440100569087, 617700440013012991,
  #     617700440013275135, 617700440092180479, 617700440091656191, 617700440092966911,
  #     617700440100831231, 617700440100044799, 617700440101617663, 617700440081956863,
  #     617700440072781823, 617700440073043967, 617700440073306111, 617700440073568255,
  #     617700440073830399, 617700440074092543, 617700440074354687
  #   ]
  #
  # @raise [RuntimeError] Couldn't attempt to umcompact H3 indexes.
  #
  # @return [Array<Integer>] Uncompacted set of H3 indexes.
  def uncompact(compacted_set : Array(UInt64), resolution : Int32) : Array(UInt64)
    max_size = max_uncompact_size(compacted_set, resolution)
    output = Pointer(UInt64).malloc(max_size)
    failure = LibH3.uncompact(compacted_set, compacted_set.size, output, max_size, Resolution.new(resolution))
    raise Exception.new("Couldn't uncompact given indexes") if failure

    read_array_of_uint64(output, max_size)
  end
end
