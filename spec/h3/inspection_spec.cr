describe H3 do
  describe ".resolution" do
    result = 8

    resolution = H3.resolution(612933930963697663)

    it { resolution.should eq(result) }
  end

  describe ".base_cell" do
    result = 12

    base_cell = H3.base_cell(612933930963697663)

    it { base_cell.should eq(result) }
  end

  describe ".from_string" do
    h3_index = "8928308280fffff"
    result : UInt64 = h3_index.to_u64(16)

    from_string = H3.from_string(h3_index)

    it { from_string.should eq(result) }
  end

  describe ".to_string" do
    h3_index = "8928308280fffff".to_u64(16)
    result = "8928308280fffff"

    to_string = H3.to_string(h3_index)

    it { to_string.should eq(result) }
  end

  describe ".valid?" do
    it "is valid" do
      h3_index = UInt64.new(612933930963697663)
      actual = H3.valid?(h3_index)
      actual.should be_true
    end

    context "when given an invalid h3_index" do
      it "is not valid" do
        h3_index = UInt64.new(1)
        actual = H3.valid?(h3_index)
        actual.should be_false
      end
    end
  end

  describe ".class_3_resolution?" do
    it "is a class 3 resolution" do
      h3_index = "8928308280fffff".to_u64(16)
      actual = H3.class_3_resolution?(h3_index)
      actual.should be_true
    end

    context "when the h3 index is not class III" do  
      it "returns false" do
        h3_index = "8828308280fffff".to_u64(16)
        actual = H3.class_3_resolution?(h3_index)
        actual.should be_false
      end
    end
  end

  describe ".pentagon?" do
    h3_index = "821c07fffffffff".to_u64(16)
    result = true

    it { H3.pentagon?(h3_index).should eq(result) }

    context "when the h3 index is not a pentagon" do
      h3_index = "8928308280fffff".to_u64(16)
      result = false

      it { H3.pentagon?(h3_index).should eq(result) }
    end
  end

  describe ".max_face_count" do
    h3_index = "8928308280fffff".to_u64(16)
    result = 2

    max_face_count = H3.max_face_count(h3_index)

    it { max_face_count.should eq(result) }

    context "when the h3 index is a pentagon" do
      h3_index = "821c07fffffffff".to_u64(16)
      result = 5

      max_face_count = H3.max_face_count(h3_index)

      it { max_face_count.should eq(result) }
    end
  end

  describe ".faces" do
    h3_index = "8928308280fffff".to_u64(16)
    result = [7]

    faces = H3.faces(h3_index)

    it { faces.should eq(result) }

    context "when the h3 index is a pentagon" do
      h3_index = "821c07fffffffff".to_u64(16)
      result = [1, 2, 6, 7, 11]

      faces = H3.faces(h3_index)

      it { faces.should eq(result) }
    end
  end
end
