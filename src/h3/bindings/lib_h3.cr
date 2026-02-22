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

        struct GeoLoop
          num_verts : Int32
          verts : Pointer(LatLng)
        end

        struct GeoPolygon
          geoloop : GeoLoop
          num_holes : Int32
          holes : Pointer(GeoLoop)
        end

        struct GeoMultiPolygon
          num_polygons : Int32
          polygons : Pointer(GeoPolygon)
        end

        struct LinkedLatLng
          vertex : LatLng
          next : Pointer(LinkedLatLng)
        end

        struct LinkedGeoLoop
          first : Pointer(LinkedLatLng)
          last : Pointer(LinkedLatLng)
          next : Pointer(LinkedGeoLoop)
        end

        struct LinkedGeoPolygon
          first : Pointer(LinkedGeoLoop)
          last : Pointer(LinkedGeoLoop)
          next : Pointer(LinkedGeoPolygon)
        end

        struct CoordIJ
          i : Int32
          j : Int32
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
        fun cell_area_rads2 = cellAreaRads2(h3_index : H3Index, out : Float64*) : H3Error
        fun cell_area_km2 = cellAreaKm2(h3_index : H3Index, out : Float64*) : H3Error
        fun cell_area_m2 = cellAreaM2(h3_index : H3Index, out : Float64*) : H3Error
        fun great_circle_distance_rads = greatCircleDistanceRads(a : Pointer(LatLng), b : Pointer(LatLng)) : Float64
        fun great_circle_distance_km = greatCircleDistanceKm(a : Pointer(LatLng), b : Pointer(LatLng)) : Float64
        fun great_circle_distance_m = greatCircleDistanceM(a : Pointer(LatLng), b : Pointer(LatLng)) : Float64

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

        # Polygon
        fun max_polygon_to_cells_size = maxPolygonToCellsSize(geo_polygon : Pointer(GeoPolygon), res : Int32, flags : UInt32, out : Int64*) : H3Error
        fun polygon_to_cells = polygonToCells(geo_polygon : Pointer(GeoPolygon), res : Int32, flags : UInt32, out : H3Index*) : H3Error
        fun cells_to_linked_multi_polygon = cellsToLinkedMultiPolygon(h3_set : H3Index*, num_hexes : Int32, out : Pointer(LinkedGeoPolygon)) : H3Error
        fun destroy_linked_multi_polygon = destroyLinkedMultiPolygon(polygon : Pointer(LinkedGeoPolygon)) : Void

        # Vertex
        fun cell_to_vertex = cellToVertex(origin : H3Index, vertex_num : Int32, out : H3Index*) : H3Error
        fun cell_to_vertexes = cellToVertexes(origin : H3Index, out : H3Index*) : H3Error
        fun vertex_to_lat_lng = vertexToLatLng(vertex : H3Index, out : Pointer(LatLng)) : H3Error
        fun is_valid_vertex = isValidVertex(vertex : H3Index) : Int32

        # Local IJ Coordinates
        fun cell_to_local_ij = cellToLocalIj(origin : H3Index, h3 : H3Index, mode : UInt32, out : CoordIJ*) : H3Error
        fun local_ij_to_cell = localIjToCell(origin : H3Index, ij : CoordIJ*, mode : UInt32, out : H3Index*) : H3Error

        # Directed Edges
        fun are_neighbor_cells = areNeighborCells(origin : H3Index, destination : H3Index, out : Int32*) : H3Error
        fun cells_to_directed_edge = cellsToDirectedEdge(origin : H3Index, destination : H3Index, out : H3Index*) : H3Error
        fun is_valid_directed_edge = isValidDirectedEdge(edge : H3Index) : Int32
        fun get_directed_edge_origin = getDirectedEdgeOrigin(edge : H3Index, out : H3Index*) : H3Error
        fun get_directed_edge_destination = getDirectedEdgeDestination(edge : H3Index, out : H3Index*) : H3Error
        fun directed_edge_to_cells = directedEdgeToCells(edge : H3Index, origin_destination : H3Index*) : H3Error
        fun origin_to_directed_edges = originToDirectedEdges(origin : H3Index, edges : H3Index*) : H3Error
        fun directed_edge_to_boundary = directedEdgeToBoundary(edge : H3Index, gb : Pointer(CellBoundary)) : H3Error
        fun exact_edge_length_rads = edgeLengthRads(edge : H3Index, length : Float64*) : H3Error
        fun exact_edge_length_km = edgeLengthKm(edge : H3Index, length : Float64*) : H3Error
        fun exact_edge_length_m = edgeLengthM(edge : H3Index, length : Float64*) : H3Error
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
