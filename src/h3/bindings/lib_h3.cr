require "./types"

module H3
  module Bindings
    module Private
      include Types

      @[Link(ldflags: "-L#{__DIR__}/../../../ext/h3/lib -lh3")]
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
      end
    end
  end
end
