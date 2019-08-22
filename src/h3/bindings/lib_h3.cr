@[Link(ldflags: "#{__DIR__}/../../../ext/h3/lib/libh3.so")]
lib LibH3
  alias H3Index = UInt64

  struct GeoCoord
    lat, lon : Float64
  end

  struct GeoBoundary
    num_verts : Int32
    verts : GeoCoord[10]
  end

  fun degs_to_rads = degsToRads(degrees : Float64) : Float64
  fun rads_to_degs = radsToDegs(rads : Float64) : Float64
  fun geo_to_h3 = geoToH3(g : Pointer(GeoCoord), res : Int32) : H3Index
  fun h3_to_geo = h3ToGeo(h3_index : H3Index, g : Pointer(GeoCoord)) : Void
  fun h3_to_geo_boundary = h3ToGeoBoundary(h3 : H3Index, gp : Pointer(GeoBoundary)) : Void
end
