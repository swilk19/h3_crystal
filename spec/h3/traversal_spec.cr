describe H3 do
  describe ".k_ring" do
    h3_index : UInt64 = "8928308280fffff".to_u64(16)

    context "when k range is 1" do
      k = 1
      count = 7
      expected =
        %w(8928308280fffff 8928308280bffff 89283082873ffff 89283082877ffff
          8928308283bffff 89283082807ffff 89283082803ffff).map { |i| i.to_u64(16) }

      k_ring = H3.k_ring(h3_index, k)

      it "has 7 hexagons" do
        k_ring.size.should eq count
      end

      it "has the expected hexagons" do
        k_ring.should eq expected
      end
    end

    context "when k range is 2" do
      k = 2
      count = 19

      k_ring = H3.k_ring(h3_index, k)

      it "has 19 hexagons" do
        k_ring.size.should eq count
      end
    end

    context "when k range is 10" do
      k = 10
      count = 331

      k_ring = H3.k_ring(h3_index, k)

      it "has 331 hexagons" do
        k_ring.size.should eq count
      end
    end
  end

  describe ".max_kring_size" do
    k = 2
    result = 19

    max_kring_size = H3.max_kring_size(k)

    it { max_kring_size.should eq(result) }
  end

  describe ".k_ring_distances" do
    h3_index = "8928308280fffff".to_u64(16)
    k = 1
    outer_ring =
      [
        "8928308280bffff", "89283082873ffff", "89283082877ffff",
        "8928308283bffff", "89283082807ffff", "89283082803ffff",
      ].map { |i| i.to_u64(16) }

    k_ring_distances = H3.k_ring_distances(h3_index, k)

    it "has two ring sets" do
      k_ring_distances.size.should eq 2
    end

    it "has an inner ring containing hexagons of distance 0" do
      k_ring_distances[0].should eq [h3_index]
    end

    it "has an outer ring containing hexagons of distance 1" do
      k_ring_distances[1].size.should eq 6
    end

    it "has an outer ring containing all expected indexes" do
      k_ring_distances[1].each do |index|
        outer_ring.should contain index
      end
    end
  end

  describe ".hex_range" do
    h3_index = "8928308280fffff".to_u64(16)

    context "when k range is 1" do
      k = 1
      count = 7
      expected =
        %w(8928308280fffff 8928308280bffff 89283082873ffff 89283082877ffff
          8928308283bffff 89283082807ffff 89283082803ffff).map { |i| i.to_u64(16) }

      hex_range = H3.hex_range(h3_index, k)

      it "has 7 hexagons" do
        hex_range.size.should eq count
      end

      it "has the expected hexagons" do
        hex_range.should eq expected
      end
    end

    context "when k range is 2" do
      k = 2
      count = 19

      hex_range = H3.hex_range(h3_index, k)

      it "has 19 hexagons" do
        hex_range.size.should eq count
      end
    end

    context "when k range is 10" do
      k = 10
      count = 331

      hex_range = H3.hex_range(h3_index, k)

      it "has 331 hexagons" do
        hex_range.size.should eq count
      end
    end

    context "when range contains a pentagon" do
      h3_index = "821c07fffffffff".to_u64(16)
      k = 1

      it "raises an error" do
        expect_raises(Exception) do
          hex_range = H3.hex_range(h3_index, k)
        end
      end
    end
  end

  describe ".hex_range_distances" do
    h3_index = "85283473fffffff".to_u64(16)
    k = 1
    outer_ring = [
      "85283447fffffff", "8528347bfffffff", "85283463fffffff",
      "85283477fffffff", "8528340ffffffff", "8528340bfffffff",
    ].map { |i| i.to_u64(16) }

    hex_range_distances = H3.hex_range_distances(h3_index, k)

    it "has two range sets" do
      hex_range_distances.size.should eq 2
    end

    it "has an inner range containing hexagons of distance 0" do
      hex_range_distances[0].should eq [h3_index]
    end

    it "has an outer range containing hexagons of distance 1" do
      hex_range_distances[1].size.should eq 6
    end

    it "has an outer range containing all expected indexes" do
      hex_range_distances[1].each do |index|
        outer_ring.should contain(index)
      end
    end

    context "when there is pentagonal distortion" do
      h3_index = "821c07fffffffff".to_u64(16)

      it "raises an error" do
        expect_raises(Exception) do
          hex_range_distances = H3.hex_range_distances(h3_index, k)
        end
      end
    end
  end

  describe ".hex_ranges" do
    h3_index = "8928308280fffff".to_u64(16)
    h3_set = [h3_index]
    k = 1
    outer_ring = [
      "8928308280bffff", "89283082807ffff", "89283082877ffff",
      "89283082803ffff", "89283082873ffff", "8928308283bffff",
    ].map { |i| i.to_u64(16) }

    hex_ranges = H3.hex_ranges_grouped(h3_set, k)

    it "contains a single k/v pair" do
      hex_ranges.size.should eq 1
    end

    it "has one key, the h3_index" do
      hex_ranges.keys.first.should eq h3_index
    end

    it "has two ring sets" do
      hex_ranges[h3_index].size.should eq 2
    end

    it "has an outer ring containing six indexes" do
      hex_ranges[h3_index].last.size.should eq 6
    end

    it "has an outer ring containing all expected indexes" do
      hex_ranges[h3_index].last.each do |index|
        outer_ring.should contain index
      end
    end

    context "when there is pentagonal distortion" do
      h3_index = "821c07fffffffff".to_u64(16)
      h3_set = [h3_index]

      it "raises an error" do
        expect_raises(Exception) do
          hex_ranges = H3.hex_ranges_grouped(h3_set, k)
        end
      end
    end

    context "when k is 2" do
      h3_index = "8928308280fffff".to_u64(16)
      h3_set = [h3_index]
      k = 2

      hex_ranges = H3.hex_ranges_grouped(h3_set, k)

      it "contains 3 rings" do
        hex_ranges[h3_index].size.should eq 3
      end

      it "has an inner ring of size 1" do
        hex_ranges[h3_index][0].size.should eq 1
      end

      it "has a middle ring of size 6" do
        hex_ranges[h3_index][1].size.should eq 6
      end

      it "has an outer ring of size 12" do
        hex_ranges[h3_index][2].size.should eq 12
      end
    end

    context "when run without grouping" do
      hex_array : Array(UInt64) = [
        617700169958293503, 617700169958031359, 617700169964847103,
        617700169965109247, 617700169961177087, 617700169957769215,
        617700169957507071,
      ].map { |i| UInt64.new(i) }
      h3_index = "8928308280fffff".to_u64(16)
      h3_set = [h3_index]
      k = 1
      hex_ranges_ungrouped = H3.hex_ranges_ungrouped(h3_set, k)

      it { hex_ranges_ungrouped.should eq hex_array }
    end

    context "when compared with the ungrouped version" do
      h3_index = "8928308280fffff".to_u64(16)
      h3_index2 = "8f19425b6ccd582".to_u64(16)
      h3_index3 = "89283082873ffff".to_u64(16)
      h3_set = [h3_index, h3_index2, h3_index3]
      k = 3

      grouped = H3.hex_ranges_grouped(h3_set, k)
      ungrouped = H3.hex_ranges_ungrouped(h3_set, k)

      it "has the same elements when we remove grouping" do
        grouped.values.flatten.should eq(ungrouped)
      end
    end
  end

  describe ".hex_ring" do
    h3_index = "8928308280fffff".to_u64(16)

    context "when k range is 1" do
      k = 1
      count = 6
      expected =
        %w(89283082803ffff 8928308280bffff 89283082873ffff 89283082877ffff
          8928308283bffff 89283082807ffff).map { |i| i.to_u64(16) }

      hex_ring = H3.hex_ring(h3_index, k)

      it "has 6 hexagons" do
        hex_ring.size.should eq count
      end

      it "has the expected hexagons" do
        hex_ring.should eq expected
      end
    end

    context "when k range is 2" do
      k = 2
      count = 12

      hex_ring = H3.hex_ring(h3_index, k)

      it "has 12 hexagons" do
        hex_ring.size.should eq count
      end
    end

    context "when k range is 10" do
      k = 10
      count = 60

      hex_ring = H3.hex_ring(h3_index, k)

      it "has 60 hexagons" do
        hex_ring.size.should eq count
      end
    end

    context "when the ring contains a pentagon" do
      h3_index = "821c07fffffffff".to_u64(16)
      k = 1

      it "raises an error" do
        expect_raises(Exception) do
          hex_ring = H3.hex_ring(h3_index, k)
        end
      end
    end
  end

  describe ".distance" do
    origin = "89283082993ffff".to_u64(16)
    destination = "89283082827ffff".to_u64(16)
    result = 5

    distance = H3.distance(origin, destination)

    it { distance.should eq(result) }
  end

  describe ".line_size" do
    origin = "89283082993ffff".to_u64(16)
    destination = "89283082827ffff".to_u64(16)
    result = 6

    h3_line_size = H3.line_size(origin, destination)

    it { h3_line_size.should eq(result) }
  end

  describe ".line" do
    origin = "89283082993ffff".to_u64(16)
    destination = "89283082827ffff".to_u64(16)
    result = [
      "89283082993ffff", "8928308299bffff", "892830829d7ffff",
      "892830829c3ffff", "892830829cbffff", "89283082827ffff",
    ].map { |i| i.to_u64(16) }

    line = H3.line(origin, destination)

    it { line.should eq(result) }
  end
end
