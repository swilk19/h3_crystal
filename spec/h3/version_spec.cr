require "../spec_helper"

private def read_value(file : String, key : String) : String
  line = File.read_lines(File.expand_path("../../#{file}", __DIR__)).find! do |l|
    l.starts_with?(key)
  end
  line.split(/[:=]/, 2)[1].gsub(/[>="\s]/, "")
end

describe "version pins" do
  it "H3::VERSION matches the version in shard.yml" do
    H3::VERSION.should eq(read_value("shard.yml", "version:"))
  end

  it "shard.yml crystal floor matches the .mise.toml crystal version" do
    read_value(".mise.toml", "crystal").should eq(read_value("shard.yml", "crystal:"))
  end
end
