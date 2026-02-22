require "spec"
require "../../src/h3/geojson"
include H3::Bindings::Types

# A polygon roughly covering part of San Francisco (GeoJSON coordinate order: [lng, lat])
SF_POLYGON_GEOJSON = GeoJSON::Polygon.new([
  [
    [-122.4089866, 37.813318],
    [-122.3805436, 37.7866302],
    [-122.3544736, 37.7198061],
    [-122.5123436, 37.7076131],
    [-122.4089866, 37.813318],
  ],
])

describe H3 do
  describe ".polygon_to_cells (GeoJSON::Polygon)" do
    context "with a simple GeoJSON polygon at resolution 9" do
      resolution = 9

      cells = H3.polygon_to_cells(SF_POLYGON_GEOJSON, resolution)

      it "returns a non-empty array" do
        cells.size.should be > 0
      end

      it "returns valid H3 indexes" do
        cells.each do |cell|
          H3.valid?(cell).should be_true
        end
      end

      it "returns cells at the correct resolution" do
        cells.each do |cell|
          H3.resolution(cell).should eq resolution
        end
      end
    end

    context "with a lower resolution" do
      resolution = 5

      cells = H3.polygon_to_cells(SF_POLYGON_GEOJSON, resolution)
      cells_high = H3.polygon_to_cells(SF_POLYGON_GEOJSON, 9)

      it "returns fewer cells than at a higher resolution" do
        cells.size.should be < cells_high.size
      end
    end

    context "with a polygon containing a hole" do
      polygon_with_hole = GeoJSON::Polygon.new([
        [
          [-122.4089866, 37.813318],
          [-122.3805436, 37.7866302],
          [-122.3544736, 37.7198061],
          [-122.5123436, 37.7076131],
          [-122.4089866, 37.813318],
        ],
        [
          [-122.42, 37.78],
          [-122.42, 37.76],
          [-122.39, 37.76],
          [-122.39, 37.78],
          [-122.42, 37.78],
        ],
      ])

      resolution = 9

      cells_with_hole = H3.polygon_to_cells(polygon_with_hole, resolution)
      cells_without_hole = H3.polygon_to_cells(SF_POLYGON_GEOJSON, resolution)

      it "returns fewer cells than without a hole" do
        cells_with_hole.size.should be < cells_without_hole.size
      end
    end

    context "when resolution is invalid" do
      it "raises an error" do
        expect_raises(Exception) do
          H3.polygon_to_cells(SF_POLYGON_GEOJSON, 16)
        end
      end
    end

    context "compared to equivalent native polygon_to_cells" do
      resolution = 7

      # H3 expects (lat, lng) tuples; GeoJSON has [lng, lat]
      native_polygon = [
        {37.813318, -122.4089866},
        {37.7866302, -122.3805436},
        {37.7198061, -122.3544736},
        {37.7076131, -122.5123436},
      ]

      native_cells = H3.polygon_to_cells(native_polygon, resolution).sort
      geojson_cells = H3.polygon_to_cells(SF_POLYGON_GEOJSON, resolution).sort

      it "returns the same cells as the native polygon_to_cells" do
        geojson_cells.should eq native_cells
      end
    end
  end

  describe ".polygon_to_cells (GeoJSON::MultiPolygon)" do
    context "with a GeoJSON MultiPolygon containing two polygons" do
      polygon1 = GeoJSON::Polygon.new([
        [
          [-122.4089866, 37.813318],
          [-122.3805436, 37.7866302],
          [-122.3544736, 37.7198061],
          [-122.5123436, 37.7076131],
          [-122.4089866, 37.813318],
        ],
      ])

      # A small separate polygon (near downtown SF)
      polygon2 = GeoJSON::Polygon.new([
        [
          [-122.415, 37.775],
          [-122.41, 37.775],
          [-122.41, 37.78],
          [-122.415, 37.78],
          [-122.415, 37.775],
        ],
      ])

      multi_polygon = GeoJSON::MultiPolygon.new([polygon1, polygon2])
      resolution = 9

      cells = H3.polygon_to_cells(multi_polygon, resolution)

      it "returns a non-empty array" do
        cells.size.should be > 0
      end

      it "returns valid H3 indexes" do
        cells.each do |cell|
          H3.valid?(cell).should be_true
        end
      end

      it "returns no duplicate cells" do
        cells.size.should eq cells.uniq.size
      end
    end
  end

  describe ".cells_to_geojson_multi_polygon" do
    context "with a single cell" do
      cells = [612933930963697663_u64]

      result = H3.cells_to_geojson_multi_polygon(cells)

      it "returns a GeoJSON::MultiPolygon" do
        result.should be_a(GeoJSON::MultiPolygon)
      end

      it "has a type of MultiPolygon" do
        result.type.should eq "MultiPolygon"
      end

      it "contains at least one polygon" do
        result.coordinates.size.should be > 0
      end

      it "contains coordinates with valid longitude values" do
        result.coordinates.each do |polygon|
          polygon.each do |ring|
            ring.each do |coord|
              coord.longitude.should be >= -180.0
              coord.longitude.should be <= 180.0
            end
          end
        end
      end

      it "contains coordinates with valid latitude values" do
        result.coordinates.each do |polygon|
          polygon.each do |ring|
            ring.each do |coord|
              coord.latitude.should be >= -90.0
              coord.latitude.should be <= 90.0
            end
          end
        end
      end
    end

    context "with contiguous cells" do
      origin = 612933930963697663_u64
      cells = H3.k_ring(origin, 1).map(&.to_u64)

      result = H3.cells_to_geojson_multi_polygon(cells)

      it "returns a GeoJSON::MultiPolygon" do
        result.should be_a(GeoJSON::MultiPolygon)
      end

      it "produces a single polygon" do
        result.coordinates.size.should eq 1
      end
    end

    context "round-trip: polygon_to_cells then cells_to_geojson_multi_polygon" do
      resolution = 7
      cells = H3.polygon_to_cells(SF_POLYGON_GEOJSON, resolution)
      result = H3.cells_to_geojson_multi_polygon(cells)

      it "produces a non-empty MultiPolygon" do
        result.coordinates.size.should be > 0
      end

      it "produces rings with coordinates" do
        total_coords = result.coordinates.sum { |poly| poly.sum { |ring| ring.size } }
        total_coords.should be > 0
      end

      it "can be serialized to JSON" do
        result.to_json.should contain("MultiPolygon")
      end
    end
  end
end
