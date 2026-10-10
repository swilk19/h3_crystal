require "../spec_helper"

private def read_value(file : String, key : String) : String
  line = File.read_lines(File.expand_path("../../#{file}", __DIR__)).find! do |l|
    l.starts_with?(key)
  end
  line.split(/[:=]/, 2)[1].gsub(/[>="\s]/, "")
end

private def ci_crystal_versions : Array(String)
  line = File.read_lines(File.expand_path("../../.github/workflows/crystal.yml", __DIR__)).find! do |l|
    l.strip.starts_with?("crystal: [")
  end
  line.split('[', 2)[1].split(']', 2)[0].split(',').map { |v| v.gsub(/["\s]/, "") }
end

describe "version pins" do
  it "H3::VERSION matches the version in shard.yml" do
    H3::VERSION.should eq(read_value("shard.yml", "version:"))
  end

  it "CI matrix includes the shard.yml crystal floor" do
    ci_crystal_versions.should contain(read_value("shard.yml", "crystal:"))
  end

  it "CI matrix includes the .mise.toml crystal version" do
    ci_crystal_versions.should contain(read_value(".mise.toml", "crystal"))
  end
end
