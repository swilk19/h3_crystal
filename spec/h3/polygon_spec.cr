describe H3 do
  # A polygon roughly covering part of San Francisco
  sf_polygon = [
    {37.813318, -122.4089866},
    {37.7866302, -122.3805436},
    {37.7198061, -122.3544736},
    {37.7076131, -122.5123436},
  ]

  describe ".max_polygon_to_cells_size" do
    context "with a simple polygon at resolution 9" do
      resolution = 9

      max_size = H3.max_polygon_to_cells_size(sf_polygon, resolution)

      it "returns a positive number" do
        max_size.should be > 0
      end
    end

    context "with a lower resolution" do
      resolution = 5

      max_size = H3.max_polygon_to_cells_size(sf_polygon, resolution)

      it "returns a smaller number than higher resolution" do
        max_size_high = H3.max_polygon_to_cells_size(sf_polygon, 9)
        max_size.should be < max_size_high
      end
    end

    context "when resolution is invalid" do
      it "raises an error" do
        expect_raises(Exception) do
          H3.max_polygon_to_cells_size(sf_polygon, 16)
        end
      end
    end
  end

  describe ".polygon_to_cells" do
    context "with a simple polygon at resolution 9" do
      resolution = 9

      cells = H3.polygon_to_cells(sf_polygon, resolution)

      it "returns a non-empty array" do
        cells.size.should be > 0
      end

      it "returns valid H3 indexes" do
        cells.each do |cell|
          H3.valid?(cell).should be_true
        end
      end

      it "returns cells at the correct resolution" do
        cells.each do |cell|
          H3.resolution(cell).should eq resolution
        end
      end
    end

    context "with a lower resolution" do
      resolution = 5

      cells = H3.polygon_to_cells(sf_polygon, resolution)

      it "returns fewer cells than at a higher resolution" do
        cells_high = H3.polygon_to_cells(sf_polygon, 9)
        cells.size.should be < cells_high.size
      end
    end

    context "with a polygon containing a hole" do
      hole = [
        {37.78, -122.42},
        {37.76, -122.42},
        {37.76, -122.39},
        {37.78, -122.39},
      ]
      resolution = 9

      cells_with_hole = H3.polygon_to_cells(sf_polygon, resolution, holes: [hole])
      cells_without_hole = H3.polygon_to_cells(sf_polygon, resolution)

      it "returns fewer cells than without a hole" do
        cells_with_hole.size.should be < cells_without_hole.size
      end
    end

    context "when resolution is invalid" do
      it "raises an error" do
        expect_raises(Exception) do
          H3.polygon_to_cells(sf_polygon, 16)
        end
      end
    end
  end

  describe ".cells_to_multi_polygon" do
    context "with a single cell" do
      cells = [H3_VALID_INDEX.to_u64]

      result = H3.cells_to_multi_polygon(cells)

      it "returns a non-empty result" do
        result.size.should be > 0
      end

      it "returns at least one polygon with at least one loop" do
        result.first.size.should be > 0
      end

      it "returns loops with coordinates" do
        result.first.first.size.should be > 0
      end

      it "returns valid coordinate pairs" do
        result.first.first.each do |lat, lng|
          lat.should be >= -90.0
          lat.should be <= 90.0
          lng.should be >= -180.0
          lng.should be <= 180.0
        end
      end
    end

    context "with contiguous cells" do
      origin = H3_VALID_INDEX.to_u64
      cells = H3.k_ring(origin, 1).map(&.to_u64)

      result = H3.cells_to_multi_polygon(cells)

      it "returns a single polygon" do
        result.size.should eq 1
      end

      it "returns a polygon with one outer loop" do
        result.first.size.should eq 1
      end
    end

    context "round-trip: polygon_to_cells then cells_to_multi_polygon" do
      resolution = 7
      cells = H3.polygon_to_cells(sf_polygon, resolution)
      result = H3.cells_to_multi_polygon(cells)

      it "produces a non-empty polygon output" do
        result.size.should be > 0
      end

      it "produces loops with coordinates" do
        total_coords = result.sum { |poly| poly.sum { |loop| loop.size } }
        total_coords.should be > 0
      end
    end
  end
end
