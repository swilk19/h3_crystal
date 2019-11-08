describe H3 do
  describe ".resolution" do
    it "has a resolution of 8" do
      H3.resolution(612933930963697663).should eq 8
    end
  end

  describe ".base_cell" do
    it "returns 12" do
      H3.base_cell(612933930963697663).should eq 12
    end
  end

  describe ".from_string" do
    it "turns a string into an h3 index" do
      h3_index = "8928308280fffff"
  
      H3.from_string(h3_index).should eq "8928308280fffff".to_u64(16)
    end
  end

  describe ".to_string" do
    it "returns the h3 index as a string" do
      h3_index = "8928308280fffff".to_u64(16)

      H3.to_string(h3_index).should eq "8928308280fffff"
    end
  end

  describe ".valid?" do
    it "is valid" do
      h3_index = UInt64.new(612933930963697663)

      H3.valid?(h3_index).should be_true
    end

    context "when given an invalid h3_index" do
      it "is not valid" do
        h3_index = UInt64.new(1)

        H3.valid?(h3_index).should be_false
      end
    end
  end

  describe ".class_3_resolution?" do
    it "is a class 3 resolution" do
      h3_index = "8928308280fffff".to_u64(16)

      H3.class_3_resolution?(h3_index).should be_true
    end

    context "when the h3 index is not class III" do  
      it "returns false" do
        h3_index = "8828308280fffff".to_u64(16)

        H3.class_3_resolution?(h3_index).should be_false
      end
    end
  end

  describe ".pentagon?" do
    context "when it is a pentagon" do
      it "returns true" do
        h3_index = "821c07fffffffff".to_u64(16)

        H3.pentagon?(h3_index).should be_true
       end
    end

    context "when the h3 index is not a pentagon" do
      it "returns false" do
        h3_index = "8928308280fffff".to_u64(16)

        H3.pentagon?(h3_index).should be_false
      end
    end
  end

  describe ".max_face_count" do
    it "has max face count of two" do
      h3_index = "8928308280fffff".to_u64(16)

      H3.max_face_count(h3_index).should eq 2
    end

    context "when the h3 index is a pentagon" do
      it "has a max face count of 5" do
        h3_index = "821c07fffffffff".to_u64(16)

        H3.max_face_count(h3_index).should eq 5
      end
    end
  end

  describe ".faces" do
    it "has one face" do
      h3_index = "8928308280fffff".to_u64(16)

      H3.faces(h3_index).should eq [7]
    end

    context "when the h3 index is a pentagon" do
      it "has five faces" do
        h3_index = "821c07fffffffff".to_u64(16)

        H3.faces(h3_index).should eq [1, 2, 6, 7, 11]
      end
    end
  end
end
