require "./spec_helper"

describe H3 do
  # TODO: Write tests

  context "indexing" do

    it "does from geo coordinates" do
      result = H3.from_geo_coordinates({53.959130, -1.079230}, Resolution.new(8))
      result.should eq(612933930963697663)

      result = H3.from_geo_coordinates({52.24630137198303, -1.7358398437499998}, Resolution.new(9))
      result.should eq(617439284584775679)
    end

    it "does to geo coordinates" do
      result = H3.to_geo_coordinates(617439284584775679)
      result.should eq({52.245519061399506, -1.7363137757391423})
    end

    it "does to boundary" do
      result = H3.to_boundary(617439284584775679)
      result.should eq([
        {52.247260929171055, -1.736809158397472}, {52.24625850761068, -1.7389279144996015},
        {52.244516619273476, -1.7384324668792375}, {52.243777169245725, -1.7358184256304658},
        {52.24477956752282, -1.7336997597088104}, {52.246521439109415, -1.7341950448552204}
      ])
    end
  end
end
