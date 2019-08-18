require "./spec_helper"

describe H3 do
  # TODO: Write tests

  it "works" do
    result = H3.from_geo_coordinates({53.959130, -1.079230}, 8)
    puts "#{result}"
    result.should eq(612933930963697663)
  end
end
