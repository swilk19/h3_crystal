describe H3 do
  # Use a known valid hex cell at resolution 9
  origin = "8928308280fffff".to_u64(16)

  describe ".cell_to_vertex" do
    it "returns a valid vertex index for vertex 0" do
      vertex = H3.cell_to_vertex(origin, 0)
      vertex.should_not eq 0
      H3.valid_vertex?(vertex).should be_true
    end

    it "returns valid vertex indexes for all 6 vertices of a hexagon" do
      6.times do |i|
        vertex = H3.cell_to_vertex(origin, i)
        vertex.should_not eq 0
        H3.valid_vertex?(vertex).should be_true
      end
    end

    it "returns different vertex indexes for different vertex numbers" do
      vertices = (0...6).map { |i| H3.cell_to_vertex(origin, i) }
      vertices.uniq.size.should eq 6
    end
  end

  describe ".cell_to_vertexes" do
    it "returns 6 vertices for a hexagonal cell" do
      vertexes = H3.cell_to_vertexes(origin)
      vertexes.size.should eq 6
    end

    it "returns all valid vertex indexes" do
      vertexes = H3.cell_to_vertexes(origin)
      vertexes.each do |vertex|
        H3.valid_vertex?(vertex).should be_true
      end
    end

    context "when the cell is a pentagon" do
      it "returns 5 vertices" do
        pentagon = "821c07fffffffff".to_u64(16)
        vertexes = H3.cell_to_vertexes(pentagon)
        vertexes.size.should eq 5
      end
    end
  end

  describe ".vertex_to_lat_lng" do
    it "returns valid coordinates for a vertex" do
      vertex = H3.cell_to_vertex(origin, 0)
      lat, lng = H3.vertex_to_lat_lng(vertex)
      lat.should be >= -90.0
      lat.should be <= 90.0
      lng.should be >= -180.0
      lng.should be <= 180.0
    end

    it "returns different coordinates for different vertices" do
      vertex0 = H3.cell_to_vertex(origin, 0)
      vertex1 = H3.cell_to_vertex(origin, 1)
      coords0 = H3.vertex_to_lat_lng(vertex0)
      coords1 = H3.vertex_to_lat_lng(vertex1)
      coords0.should_not eq coords1
    end
  end

  describe ".valid_vertex?" do
    it "returns true for a valid vertex" do
      vertex = H3.cell_to_vertex(origin, 0)
      H3.valid_vertex?(vertex).should be_true
    end

    context "when given a cell index instead of a vertex" do
      it "returns false" do
        H3.valid_vertex?(origin).should be_false
      end
    end

    context "when given an invalid index" do
      it "returns false" do
        H3.valid_vertex?(0_u64).should be_false
      end
    end
  end

  describe ".cell_to_local_ij" do
    it "converts a cell to IJ coordinates relative to an origin" do
      # Use a neighbor of origin
      neighbor = H3.k_ring(origin, 1).reject { |h| h == origin }.first
      i, j = H3.cell_to_local_ij(origin, neighbor)
      # The neighbor should have non-zero IJ coordinates relative to origin
      (i != 0 || j != 0).should be_true
    end

    it "returns consistent IJ coordinates for the origin cell itself" do
      i, j = H3.cell_to_local_ij(origin, origin)
      # The origin relative to itself should round-trip back
      result = H3.local_ij_to_cell(origin, {i, j})
      result.should eq origin
    end
  end

  describe ".local_ij_to_cell" do
    it "converts IJ coordinates back to a cell index" do
      neighbor = H3.k_ring(origin, 1).reject { |h| h == origin }.first
      ij = H3.cell_to_local_ij(origin, neighbor)
      result = H3.local_ij_to_cell(origin, ij)
      result.should eq neighbor
    end

    it "round-trips through cell_to_local_ij and back" do
      neighbors = H3.k_ring(origin, 1)
      neighbors.each do |cell|
        ij = H3.cell_to_local_ij(origin, cell)
        result = H3.local_ij_to_cell(origin, ij)
        result.should eq cell
      end
    end
  end
end
