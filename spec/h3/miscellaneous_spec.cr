describe H3 do
  describe ".hexagon_count" do
    resolution = 2
    result = 5882

    hexagon_count = H3.hexagon_count(resolution)

    it { hexagon_count.should eq(result) }
  end

  describe ".degs_to_rads" do
    degs = 100.0
    degs_to_rads = H3.degs_to_rads(degs)

    it { degs_to_rads.should eq(1.7453292519943295) }
  end

  describe ".rads_to_degs" do
    rads = 1.7453292519943295
    rads_to_degs = H3.rads_to_degs(rads)

    it { rads_to_degs.should eq(100) }
  end

  describe ".hex_area_km2" do
    resolution = 2
    result = 86801.7803989972

    hex_area_km2 = H3.hex_area_km2(resolution)

    it { hex_area_km2.should eq(result) }
  end

  describe ".hex_area_m2" do
    resolution = 2
    result = 86801780398.99731

    hex_area_m2 = H3.hex_area_m2(resolution)

    it { hex_area_m2.should eq(result) }
  end

  describe ".edge_length_km" do
    resolution = 2
    result = 182.5129565

    edge_length_km = H3.edge_length_km(resolution)

    it { edge_length_km.should eq(result) }
  end

  describe ".edge_length_m" do
    resolution = 2
    result = 182512.9565

    edge_length_m = H3.edge_length_m(resolution)

    it { edge_length_m.should eq(result) }
  end

  describe ".base_cells" do
    count = 122
    base_cells = H3.base_cells

    it "has 122 base cells" do
      base_cells.size.should eq(count)
    end
  end

  describe ".pentagon_count" do
    count = 12

    pentagon_count = H3.pentagon_count

    it "has 12 pentagons per resolution" do
      pentagon_count.should eq(count)
    end
  end

  describe ".pentagons" do
    resolution = 4
    expected = [
      594615896891195391, 594967740612083711,
      595319584332972031, 595812165542215679,
      596199193635192831, 596515852983992319,
      596691774844436479, 597008434193235967,
      597395462286213119, 597888043495456767,
      598239887216345087, 598591730937233407,
    ]
    pentagons = H3.pentagons(resolution)

    it "returns pentagons at the given resolution" do
      pentagons.should eq(expected)
    end
  end

  describe ".cell_area_rads2" do
    it "returns a positive area for a valid cell" do
      area = H3.cell_area_rads2(H3_VALID_INDEX.to_u64)
      area.should be > 0.0
    end
  end

  describe ".cell_area_km2" do
    it "returns a positive area for a valid cell" do
      area = H3.cell_area_km2(H3_VALID_INDEX.to_u64)
      area.should be > 0.0
    end
  end

  describe ".cell_area_m2" do
    it "returns a positive area for a valid cell" do
      area = H3.cell_area_m2(H3_VALID_INDEX.to_u64)
      area.should be > 0.0
    end

    it "is consistent with km2 measurement" do
      area_m2 = H3.cell_area_m2(H3_VALID_INDEX.to_u64)
      area_km2 = H3.cell_area_km2(H3_VALID_INDEX.to_u64)
      (area_m2 / 1_000_000.0).should be_close(area_km2, 0.0001)
    end
  end

  describe ".great_circle_distance_rads" do
    it "returns the correct distance between two points" do
      distance = H3.great_circle_distance_rads(0.0, 0.0, 1.0, 0.0)
      distance.should be > 0.0
      distance.should be_close(0.017453292519943295, 0.0001)
    end

    it "returns zero for the same point" do
      distance = H3.great_circle_distance_rads(40.0, -74.0, 40.0, -74.0)
      distance.should eq(0.0)
    end
  end

  describe ".great_circle_distance_km" do
    it "returns the correct distance between two points" do
      # Distance from equator at (0,0) to (1,0) should be ~111.195 km
      distance = H3.great_circle_distance_km(0.0, 0.0, 1.0, 0.0)
      distance.should be > 0.0
      distance.should be_close(111.195, 0.1)
    end

    it "returns zero for the same point" do
      distance = H3.great_circle_distance_km(40.0, -74.0, 40.0, -74.0)
      distance.should eq(0.0)
    end
  end

  describe ".great_circle_distance_m" do
    it "returns the correct distance between two points" do
      distance = H3.great_circle_distance_m(0.0, 0.0, 1.0, 0.0)
      distance.should be > 0.0
      distance.should be_close(111195.0, 100.0)
    end

    it "is consistent with km measurement" do
      distance_m = H3.great_circle_distance_m(0.0, 0.0, 1.0, 0.0)
      distance_km = H3.great_circle_distance_km(0.0, 0.0, 1.0, 0.0)
      (distance_m / 1000.0).should be_close(distance_km, 0.0001)
    end

    it "returns zero for the same point" do
      distance = H3.great_circle_distance_m(40.0, -74.0, 40.0, -74.0)
      distance.should eq(0.0)
    end
  end
end
