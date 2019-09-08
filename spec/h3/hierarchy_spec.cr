describe H3 do
  describe ".parent" do
    h3_index = "89283082993ffff".to_u64(16)
    parent_resolution = 8
    result = "8828308299fffff".to_u64(16)

    parent = H3.parent(h3_index, parent_resolution)

    it { parent.should eq(result) }
  end

  describe ".children" do
    h3_index = "8928308280fffff".to_u64(16)

    context "when resolution is 3" do
      child_resolution = 3
      count = 0

      children = H3.children(h3_index, child_resolution)

      it "has 0 children" do
        children.size.should eq count
      end
    end

    context "when resolution is 9" do
      child_resolution = 9
      count = 1
      expected = "8928308280fffff".to_u64(16)

      children = H3.children(h3_index, child_resolution)

      it "has 1 child" do
        children.size.should eq count
      end

      it "is the expected value" do
        children.first.should eq expected
      end
    end

    context "when resolution is 10" do
      child_resolution = 10
      count = 7

      children = H3.children(h3_index, child_resolution)

      it "has 7 children" do
        children.size.should eq count
      end
    end

    context "when resolution is 15" do
      child_resolution = 15
      count = 117649

      children = H3.children(h3_index, child_resolution)

      it "has 117649 children" do
        children.size.should eq count
      end
    end

    context "when the resolution is -1" do
      child_resolution = -1

      it "raises an error" do
        expect_raises(Exception) do
          children = H3.children(h3_index, child_resolution)
        end
      end
    end

    context "when the resolution is 16" do
      child_resolution = 16

      it "raises an error" do
        expect_raises(Exception) do
          children = H3.children(h3_index, child_resolution)
        end
      end
    end
  end

  describe ".max_children" do
    h3_index = "8928308280fffff".to_u64(16)

    context "when resolution is 3" do
      child_resolution = 3
      count = 0

      max_children = H3.max_children(h3_index, child_resolution)

      it { max_children.should eq(count) }
    end

    context "when resolution is 9" do
      child_resolution = 9
      count = 1

      max_children = H3.max_children(h3_index, child_resolution)

      it { max_children.should eq(count) }
    end

    context "when resolution is 10" do
      child_resolution = 10
      count = 7

      max_children = H3.max_children(h3_index, child_resolution)

      it { max_children.should eq(count) }
    end

    context "when resolution is 15" do
      child_resolution = 15
      count = 117649

      max_children = H3.max_children(h3_index, child_resolution)

      it { max_children.should eq(count) }
    end
  end

  describe ".compact" do
    h3_index = "89283470c27ffff".to_u64(16)
    k = 9

    uncompacted = H3.k_ring(h3_index, k)
    compact = H3.compact(uncompacted)

    it "has an uncompacted size of 271" do
      uncompacted.size.should eq 271
    end

    it "has a compacted size of 73" do
      compact.size.should eq 73
    end
  end

  describe ".uncompact" do
    h3_index = "89283470c27ffff".to_u64(16)
    resolution = 9
    uncompacted = H3.k_ring(h3_index, resolution)
    compacted = H3.compact(uncompacted)

    uncompact = H3.uncompact(compacted, resolution)

    it "has an uncompacted size of 271" do
      uncompact.size.should eq 271
    end

    it "has a compacted size of 73" do
      compacted.size.should eq 73
    end

    context "when resolution is incorrect for index" do
      resolution = 8

      it "raises error" do
        expect_raises(Exception) do
          uncompact = H3.uncompact(compacted, resolution)
        end
      end
    end
  end

  describe ".max_uncompact_size" do
    h3_indexes = ["8928308280fffff", "89283470893ffff"].map { |i| i.to_u64(16) }
    resolution = 9
    result = 2

    max_uncompact_size = H3.max_uncompact_size(h3_indexes, resolution)

    it { max_uncompact_size.should eq result }

    context "when resolution is incorrect for index" do
      resolution = 8

      it "raises an error" do
        expect_raises(Exception) do
          max_uncompact_size = H3.max_uncompact_size(h3_indexes, resolution)
        end
      end
    end
  end

  describe ".center_child" do
    h3_index = "8828308299fffff".to_u64(16)
    resolution = 10
    result = "8a2830829807fff".to_u64(16)

    center_child = H3.center_child(h3_index, resolution)

    it { center_child.should eq result }
  end
end
