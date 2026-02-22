require "./types"

module H3
  module Bindings
    module Private
      include Types

      @[Link(ldflags: "#{__DIR__}/../../../ext/h3/build/lib/libh3.a -lm")]
      lib LibH3
        alias H3Index = UInt64
        alias H3Error = UInt32

        struct LatLng
          lat, lng : Float64
        end

        struct CellBoundary
          num_verts : Int32
          verts : LatLng[10]
        end

        # Misc
        fun degs_to_rads = degsToRads(degrees : Float64) : Float64
        fun rads_to_degs = radsToDegs(rads : Float64) : Float64
        fun hexagon_count = getNumCells(res : Int32, out : Int64*) : H3Error
        fun pentagon_count = pentagonCount : Int32
        fun hex_area_km2 = getHexagonAreaAvgKm2(res : Int32, out : Float64*) : H3Error
        fun hex_area_m2 = getHexagonAreaAvgM2(res : Int32, out : Float64*) : H3Error
        fun edge_length_km = getHexagonEdgeLengthAvgKm(res : Int32, out : Float64*) : H3Error
        fun edge_length_m = getHexagonEdgeLengthAvgM(res : Int32, out : Float64*) : H3Error
        fun res_0_cells = getRes0Cells(h3_indexes_out : H3Index*) : H3Error
        fun base_cell_count = res0CellCount : Int32
        fun get_pentagons = getPentagons(res : Int32, h3_indexes_out : H3Index*) : H3Error

        # Indexing
        fun lat_lng_to_cell = latLngToCell(g : Pointer(LatLng), res : Int32, out : H3Index*) : H3Error
        fun cell_to_lat_lng = cellToLatLng(h3_index : H3Index, g : Pointer(LatLng)) : H3Error
        fun cell_to_boundary = cellToBoundary(h3 : H3Index, gp : Pointer(CellBoundary)) : H3Error

        # Inspection
        fun resolution = getResolution(h3_index : H3Index) : Int32
        fun base_cell = getBaseCellNumber(h3_index : H3Index) : Int32
        fun from_string = stringToH3(input : LibC::Char*, out : H3Index*) : H3Error
        fun pentagon? = isPentagon(h3_index : H3Index) : Int32
        fun class_3_resolution? = isResClassIII(h3_index : H3Index) : Int32
        fun valid? = isValidCell(h3_index : H3Index) : Int32
        fun h3_to_string = h3ToString(h3_index : H3Index, output_buffer : LibC::Char*, size : LibC::SizeT) : H3Error
        fun max_face_count = maxFaceCount(h3_index : H3Index, out : Int32*) : H3Error
        fun h3_faces = getIcosahedronFaces(h3_index : H3Index, output_buffer : LibC::Int*) : H3Error

        # Traversal
        fun max_grid_disk_size = maxGridDiskSize(k : Int32, out : Int64*) : H3Error
        fun hex_ring = gridRingUnsafe(h3_index : H3Index, k_distance : Int32, output : H3Index*) : H3Error
        fun k_ring = gridDisk(h3_index : H3Index, k_distance : Int32, output : H3Index*) : H3Error
        fun k_ring_distances = gridDiskDistances(h3_index : H3Index, k_distance : Int32, h3_indexes_out : H3Index*, distances : Int32*) : H3Error
        fun hex_range = gridDiskUnsafe(h3_index : H3Index, k_distance : Int32, h3_indexes_out : H3Index*) : H3Error
        fun hex_range_distances = gridDiskDistancesUnsafe(h3_index : H3Index, k_distance : Int32, h3_indexes_out : H3Index*, output_buffer : Int32*) : H3Error
        fun hex_ranges = gridDisksUnsafe(h3_indexes_in : H3Index*, size : Int32, k_distance : Int32, h3_indexes_out : H3Index*) : H3Error
        fun distance = gridDistance(origin : H3Index, destination : H3Index, out : Int64*) : H3Error
        fun line_size = gridPathCellsSize(start : H3Index, end_point : H3Index, out : Int64*) : H3Error
        fun h3_line = gridPathCells(start : H3Index, destination : H3Index, output : H3Index*) : H3Error

        # Hierarchy
        fun parent = cellToParent(h3_index : H3Index, res : Int32, out : H3Index*) : H3Error
        fun max_children = cellToChildrenSize(h3_index : H3Index, res : Int32, out : Int64*) : H3Error
        fun h3_to_children = cellToChildren(h3_index : H3Index, res : Int32, h3_indexes_out : H3Index*) : H3Error
        fun compact = compactCells(h3_set : H3Index*, compacted_set : H3Index*, size : Int64) : H3Error
        fun max_uncompact_size = uncompactCellsSize(h3_set : H3Index*, size : Int64, res : Int32, out : Int64*) : H3Error
        fun uncompact = uncompactCells(h3_set : H3Index*, size : Int64, h3_indexes_out : H3Index*, max_hexes : Int64, res : Int32) : H3Error
        fun center_child = cellToCenterChild(h3_index : H3Index, res : Int32, out : H3Index*) : H3Error
        fun cell_to_child_pos = cellToChildPos(child : H3Index, parent_res : Int32, out : Int64*) : H3Error
        fun child_pos_to_cell = childPosToCell(child_pos : Int64, parent : H3Index, child_res : Int32, out : H3Index*) : H3Error
      end

      def read_array_of_uint64(ptr : Pointer(UInt64), size : Int) : Array(UInt64)
        Array(UInt64).new(size) { |i| ptr[i] }.reject! { |value| value.zero? }
      end

      def read_array_of_int32(ptr : Pointer(Int32), size : Int) : Array(Int32)
        Array(Int32).new(size) { |i| ptr[i] }
      end
    end
  end
end
