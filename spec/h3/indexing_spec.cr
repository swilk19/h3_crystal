describe H3 do
    describe ".from_geo_coordinates" do
      it "translates coordinates into an h3 index" do
        resolution = 8
        coords = {53.959130, -1.079230}
        actual = H3.from_geo_coordinates(coords, resolution)
        
        actual.should eq(H3_VALID_INDEX)
      end

      context "when given bad coordinates" do
        coords = {-1.1323222, 190.1020102}
        resolution = 8

        it "throws an error" do
          expect_raises(Exception) do
            H3.from_geo_coordinates(coords, resolution)
          end
        end
      end    
    end

    describe ".to_geo_coordinates" do
      h3_index : UInt64 = 612933930963697663
      expected_lat = 53.95860421941
      expected_lon = -1.08119564709
  
      actual = H3.to_geo_coordinates(h3_index)
  
      it "should return the expected latitude" do
        actual[0].should be_close(expected_lat, 0.000001)
      end
  
      it "should return the expected longitude" do
        actual[1].should be_close(expected_lon, 0.000001)
      end
    end
    
    describe ".to_boundary" do
      h3_index : UInt64 = 599686042433355775
      expected = [
        {37.2713558667319, -121.91508032705622},
        {37.353926450852256, -121.8622232890249},
        {37.42834118609435, -121.92354999630156},
        {37.42012867767779, -122.03773496427027},
        {37.33755608435299, -122.090428929044},
        {37.26319797461824, -122.02910130918998}
      ]      

      to_boundary = H3.to_boundary(h3_index)
  
      it "matches expected boundary coordinates" do
        to_boundary.zip(expected) do |(lat, lon), (exp_lat, exp_lon)|
          lat.should be_close(exp_lat, 0.000001)
          lon.should be_close(exp_lon, 0.000001)
        end
      end
    end
  end
  