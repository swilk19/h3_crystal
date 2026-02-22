describe H3 do
  # Use two known neighboring cells at resolution 9
  origin = "8928308280fffff".to_u64(16)
  destination = "8928308280bffff".to_u64(16)

  describe ".are_neighbor_cells" do
    it "returns true for neighboring cells" do
      H3.are_neighbor_cells(origin, destination).should be_true
    end

    context "when cells are not neighbors" do
      it "returns false" do
        far_away = "89283082993ffff".to_u64(16)
        H3.are_neighbor_cells(origin, far_away).should be_false
      end
    end
  end

  describe ".cells_to_directed_edge" do
    it "returns a directed edge index for neighboring cells" do
      edge = H3.cells_to_directed_edge(origin, destination)
      edge.should_not eq 0
      H3.valid_directed_edge?(edge).should be_true
    end
  end

  describe ".valid_directed_edge?" do
    it "returns true for a valid directed edge" do
      edge = H3.cells_to_directed_edge(origin, destination)
      H3.valid_directed_edge?(edge).should be_true
    end

    context "when the index is not a directed edge" do
      it "returns false" do
        H3.valid_directed_edge?(origin).should be_false
      end
    end

    context "when given an invalid index" do
      it "returns false" do
        H3.valid_directed_edge?(0_u64).should be_false
      end
    end
  end

  describe ".directed_edge_origin" do
    it "returns the origin cell" do
      edge = H3.cells_to_directed_edge(origin, destination)
      H3.directed_edge_origin(edge).should eq origin
    end
  end

  describe ".directed_edge_destination" do
    it "returns the destination cell" do
      edge = H3.cells_to_directed_edge(origin, destination)
      H3.directed_edge_destination(edge).should eq destination
    end
  end

  describe ".directed_edge_to_cells" do
    it "returns origin and destination cells" do
      edge = H3.cells_to_directed_edge(origin, destination)
      cells = H3.directed_edge_to_cells(edge)
      cells[0].should eq origin
      cells[1].should eq destination
    end
  end

  describe ".origin_to_directed_edges" do
    it "returns 6 directed edges for a hexagon" do
      edges = H3.origin_to_directed_edges(origin)
      edges.size.should eq 6
    end

    it "returns valid directed edges" do
      edges = H3.origin_to_directed_edges(origin)
      edges.each do |edge|
        H3.valid_directed_edge?(edge).should be_true
      end
    end

    it "returns edges that all originate from the given cell" do
      edges = H3.origin_to_directed_edges(origin)
      edges.each do |edge|
        H3.directed_edge_origin(edge).should eq origin
      end
    end

    context "when the cell is a pentagon" do
      it "returns 5 directed edges" do
        pentagon = "821c07fffffffff".to_u64(16)
        edges = H3.origin_to_directed_edges(pentagon)
        edges.size.should eq 5
      end
    end
  end

  describe ".directed_edge_to_boundary" do
    it "returns boundary coordinates for a directed edge" do
      edge = H3.cells_to_directed_edge(origin, destination)
      boundary = H3.directed_edge_to_boundary(edge)
      boundary.size.should be > 0
    end

    it "returns valid coordinate pairs" do
      edge = H3.cells_to_directed_edge(origin, destination)
      boundary = H3.directed_edge_to_boundary(edge)
      boundary.each do |(lat, lng)|
        lat.should be >= -90.0
        lat.should be <= 90.0
        lng.should be >= -180.0
        lng.should be <= 180.0
      end
    end
  end

  describe ".exact_edge_length_rads" do
    it "returns the edge length in radians" do
      edge = H3.cells_to_directed_edge(origin, destination)
      length = H3.exact_edge_length_rads(edge)
      length.should be > 0.0
    end
  end

  describe ".exact_edge_length_km" do
    it "returns the edge length in kilometres" do
      edge = H3.cells_to_directed_edge(origin, destination)
      length = H3.exact_edge_length_km(edge)
      length.should be > 0.0
    end

    it "returns a reasonable value" do
      edge = H3.cells_to_directed_edge(origin, destination)
      length = H3.exact_edge_length_km(edge)
      # Resolution 9 edges should be on the order of a fraction of a km
      length.should be < 1.0
      length.should be > 0.0
    end
  end

  describe ".exact_edge_length_m" do
    it "returns the edge length in metres" do
      edge = H3.cells_to_directed_edge(origin, destination)
      length = H3.exact_edge_length_m(edge)
      length.should be > 0.0
    end

    it "is consistent with km measurement" do
      edge = H3.cells_to_directed_edge(origin, destination)
      length_m = H3.exact_edge_length_m(edge)
      length_km = H3.exact_edge_length_km(edge)
      (length_m / 1000.0).should be_close(length_km, 0.0001)
    end
  end
end
