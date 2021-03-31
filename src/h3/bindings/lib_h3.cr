require "./types"

module H3
  module Bindings
    module Private
      include Types

      @[Link("h3")]
      lib LibH3
        alias H3Index = UInt64

        struct GeoCoord
          lat, lon : Float64
        end

        struct GeoBoundary
          num_verts : Int32
          verts : GeoCoord[10]
        end

        # Misc
        fun degs_to_rads = degsToRads(degrees : Float64) : Float64
        fun rads_to_degs = radsToDegs(rads : Float64) : Float64
        fun hexagon_count = numHexagons(res : Int32) : UInt64
        fun pentagon_count = pentagonIndexCount : Int32
        fun hex_area_km2 = hexAreaKm2(res : Int32) : Float64
        fun hex_area_m2 = hexAreaM2(res : Int32) : Float64
        fun edge_length_km = edgeLengthKm(res : Int32) : Float64
        fun edge_length_m = edgeLengthM(res : Int32) : Float64
        fun res_0_indexes = getRes0Indexes(h3_indexes_out : StaticArray(H3Index, 122)*) : Void
        fun base_cell_count = res0IndexCount : Int32
        fun get_pentagon_indexes = getPentagonIndexes(res : Int32, h3_indexes_out : StaticArray(H3Index, 12)*) : Void

        # Indexing
        fun geo_to_h3 = geoToH3(g : Pointer(GeoCoord), res : Int32) : H3Index
        fun h3_to_geo = h3ToGeo(h3_index : H3Index, g : Pointer(GeoCoord)) : Void
        fun h3_to_geo_boundary = h3ToGeoBoundary(h3 : H3Index, gp : Pointer(GeoBoundary)) : Void

        # Inspection
        fun resolution = h3GetResolution(h3_index : H3Index) : Int32
        fun base_cell = h3GetBaseCell(h3_index : H3Index) : Int32
        fun from_string = stringToH3(input : LibC::Char*) : UInt64
        fun pentagon? = h3IsPentagon(h3_index : H3Index) : Bool
        fun class_3_resolution? = h3IsResClassIII(h3_index : H3Index) : Bool
        fun valid? = h3IsValid(h3_index : H3Index) : Bool
        fun h3_to_string = h3ToString(h3_index : H3Index, output_buffer : LibC::Char*, size : LibC::SizeT) : Void
        fun max_face_count = maxFaceCount(h3_index : H3Index) : Int32
        fun h3_faces = h3GetFaces(h3_index : H3Index, output_buffer : LibC::Int*)

        # Traversal
        fun max_kring_size = maxKringSize(k : LibC::SizeT) : Int32
        fun hex_ring = hexRing(h3_index : H3Index, k_distance : LibC::SizeT, output : H3Index*) : Bool
        fun k_ring = kRing(h3_index : H3Index, k_distance : LibC::SizeT, output : H3Index*) : Void
        fun k_ring_distances = kRingDistances(h3_index : H3Index, k_distance : LibC::SizeT, h3_indexes_out : H3Index*, distances : Int32*) : Void
        fun hex_range = hexRange(h3_index : H3Index, k_distance : LibC::SizeT, h3_indexes_out : H3Index*) : Bool
        fun hex_range_distances = hexRangeDistances(h3_index : H3Index, k_distance : LibC::SizeT, h3_indexes_out : H3Index*, output_buffer : Int32*) : Bool
        fun hex_ranges = hexRanges(h3_indexes_in : H3Index*, size : LibC::SizeT, k_distance : LibC::SizeT, h3_indexes_out : H3Index*) : Bool
        fun distance = h3Distance(origin : H3Index, destination : H3Index) : Int32
        fun line_size = h3LineSize(start : H3Index, end_point : H3Index) : Int32
        fun h3_line = h3Line(start : H3Index, destination : H3Index, output : H3Index*) : Int32

        # Hierarchy
        fun parent = h3ToParent(h3_index : H3Index, res : Int32) : H3Index
        fun max_children = maxH3ToChildrenSize(h3_index : H3Index, res : Int32) : Int32
        fun h3_to_children = h3ToChildren(h3_index : H3Index, res : Int32, h3_indexes_out : H3Index*) : Void
        fun compact = compact(h3_set : H3Index*, compacted_set : H3Index*, size : Int32) : Bool
        fun max_uncompact_size = maxUncompactSize(h3_set : H3Index*, size : LibC::SizeT, res : Int32) : Int32
        fun uncompact = uncompact(h3_set : H3Index*, size : LibC::SizeT, h3_indexes_out : H3Index*, size : LibC::SizeT, res : Int32) : Bool
        fun center_child = h3ToCenterChild(h3_index : H3Index, res : Int32) : UInt64
      end

      def read_array_of_uint64(ptr : Pointer(UInt64), size : Int32) : Array(UInt64)
        Array(UInt64).new(size) { |i| ptr[i] }.reject! { |value| value.zero? }
      end

      def read_array_of_int32(ptr : Pointer(Int32), size : Int32) : Array(Int32)
        Array(Int32).new(size) { |i| ptr[i] }
      end
    end
  end
end
