@[Link(ldflags: "#{__DIR__}/../../../ext/h3/lib/libh3.dylib")]
lib LibH3
  alias H3Index = UInt64
  # attach_function :geo_to_h3, :geoToH3, [GeoCoord, Resolution], :h3_index
  struct GeoCoord
    lat, lon : Float64
  end

  fun degs_to_rads = degsToRads(degrees : Float64) : Float64
    # attach_function :rads_to_degs, :radsToDegs, %i[double], :double
  fun rads_to_degs = radsToDegs(rads : Float64) : Float64
  fun geo_to_h3 = geoToH3(g : Pointer(GeoCoord), res : Int32) : H3Index
    # attach_function :h3_to_geo, :h3ToGeo, [:h3_index, GeoCoord], :void
  fun h3_to_geo = h3ToGeo(h3_index: H3Index, g : Pointer(GeoCoord)) : Void
end