@[Link(ldflags: "#{__DIR__}/../../../ext/h3/lib/libh3.dylib")]
lib LibH3
  # attach_function :geo_to_h3, :geoToH3, [GeoCoord, Resolution], :h3_index
  struct GeoCoord
    lat, lon : Float64
  end

  fun degs_to_rads = degsToRads(degrees : Float64) : Float64
  
  fun geo_to_h3 = geoToH3(g : Pointer(GeoCoord), res : Int32) : UInt64
end