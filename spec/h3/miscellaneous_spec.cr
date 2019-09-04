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
    result = 86745.85403

    hex_area_km2 = H3.hex_area_km2(resolution)

    it { hex_area_km2.should eq(result) }
  end

  describe ".hex_area_m2" do
    resolution = 2
    result = 86745854035.0

    hex_area_m2 = H3.hex_area_m2(resolution)

    it { hex_area_m2.should eq(result) }
  end

  describe ".edge_length_km" do
    resolution = 2
    result = 158.2446558

    edge_length_km = H3.edge_length_km(resolution)

    it { edge_length_km.should eq(result) }
  end

  describe ".edge_length_m" do
    resolution = 2
    result = 158244.6558

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
        598239887216345087, 598591730937233407
      ]
    pentagons = H3.pentagons(resolution)

    it "returns pentagons at the given resolution" do
      pentagons.should eq(expected)
    end
  end
end
