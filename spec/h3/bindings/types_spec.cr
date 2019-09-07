describe H3 do
  it "should raise an error if resolution out of bounds" do
    expect_raises(Exception) do
      Resolution.new(100)
    end
  end

  it "should allow a normal resolution" do
    expected = 2
    Resolution.new(2).value.should eq(expected)
  end
end
