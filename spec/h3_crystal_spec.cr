require "./spec_helper"

describe H3 do
  # TODO: Write tests

  context "indexing" do

    it "does from geo coordinates" do
      result = H3.from_geo_coordinates({53.959130, -1.079230}, 8)
      result.should eq(612933930963697663)

      result = H3.from_geo_coordinates({52.24630137198303, -1.7358398437499998}, 9)
      result.should eq(617439284584775679)
    end

    it "does to geo coordinates" do
      result = H3.to_geo_coordinates(617439284584775679)
      result.should eq({52.245519061399506, -1.7363137757391423})
    end
  end
end
