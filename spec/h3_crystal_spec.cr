require "./spec_helper"

describe H3 do
  # TODO: Write tests

  it "works" do
    result = H3.from_geo_coordinates({53.959130, -1.079230}, 8)
    result.should eq(612933930963697663)

    result = H3.from_geo_coordinates({52.24630137198303, -1.7358398437499998}, 9)
    result.should eq(617439284584775679)
  end
end
