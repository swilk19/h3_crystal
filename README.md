# H3 Crystal

![h3](https://user-images.githubusercontent.com/98526/50283275-48177300-044d-11e9-8337-eba8d3cc88a2.png)

![build](https://github.com/swilk19/h3_crystal/workflows/build/badge.svg)

Crystal bindings for Uber's [H3 hexagonal spatial indexing library](https://h3geo.org/). Wraps the H3 C library v4.4.1 via Crystal's FFI with static linking — no system-level H3 install needed.

Please consult [the H3 documentation](https://h3geo.org/docs/) for a full explanation of terminology and concepts.

## Supported H3 Versions

The semantic versioning of this shard matches the versioning of the H3 C library. E.g. version `4.4.x` of this shard is targeted for version `4.4.y` of H3 C lib where `x` and `y` are independent patch levels.

## Installation

Before installing, ensure you have CMake and a C compiler available (see [H3 build dependencies](https://github.com/uber/h3/blob/v4.4.1/README.md#install-build-time-dependencies)).

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     h3_crystal:
       github: swilk19/h3_crystal
   ```

2. Run `shards install`

The H3 C library is compiled from bundled source during installation and statically linked.

## Usage

```crystal
require "h3_crystal/h3"

# Convert coordinates to an H3 cell index
index = H3.from_geo_coordinates({40.689167, -74.044444}, 8)
# => 613229551440363519

# Inspect the index
H3.valid?(index)     # => true
H3.resolution(index) # => 8
H3.pentagon?(index)  # => false

# Convert back to coordinates
H3.to_geo_coordinates(index)
# => {40.68762931583634, -74.04099997186306}

# Find neighboring hexagons
H3.k_ring(index, 1) # => [613229551440363519, ...]  (7 cells)

# Get parent/children
H3.parent(index, 7)      # => parent cell at resolution 7
H3.children(index, 9)    # => array of child cells at resolution 9

# Measure distances
H3.distance(origin, destination) # => grid distance in cells
H3.great_circle_distance_km(lat1, lng1, lat2, lng2) # => km

# Work with directed edges
H3.origin_to_directed_edges(index) # => 6 directed edge indexes
H3.exact_edge_length_km(edge)      # => edge length in km

# Fill a polygon with hexagons
polygon = [{37.813318, -122.4089866}, {37.7866302, -122.3805436},
           {37.7198061, -122.3544736}, {37.7076131, -122.5123436}]
H3.polygon_to_cells(polygon, 9) # => array of H3 indexes
```

All public methods are called as `H3.method_name`.

## API Coverage

This shard covers **97% of the H3 v4 API** (75 of 77 exported C functions).

### Indexing

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `from_geo_coordinates` | `latLngToCell` | Convert lat/lng to H3 index |
| `to_geo_coordinates` | `cellToLatLng` | Convert H3 index to lat/lng |
| `to_boundary` | `cellToBoundary` | Get cell boundary coordinates |

### Inspection

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `resolution` | `getResolution` | Get resolution of an index |
| `base_cell` | `getBaseCellNumber` | Get base cell number |
| `from_string` | `stringToH3` | Parse hex string to index |
| `to_string` | `h3ToString` | Convert index to hex string |
| `valid?` | `isValidCell` | Check if cell index is valid |
| `valid_index?` | `isValidIndex` | Check if any H3 index is valid |
| `pentagon?` | `isPentagon` | Check if cell is a pentagon |
| `class_3_resolution?` | `isResClassIII` | Check if Class III resolution |
| `max_face_count` | `maxFaceCount` | Max icosahedron faces for cell |
| `faces` | `getIcosahedronFaces` | Get icosahedron face set |

### Traversal

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `k_ring` | `gridDisk` | All cells within k distance |
| `k_ring_distances` | `gridDiskDistances` | Cells grouped by distance |
| `hex_range` | `gridDiskUnsafe` | Cells within k (no pentagons) |
| `hex_range_distances` | `gridDiskDistancesUnsafe` | Grouped by distance (no pentagons) |
| `hex_ring` | `gridRingUnsafe` | Hollow ring at distance k |
| `hex_ranges` | `gridDisksUnsafe` | Multi-origin disk (no pentagons) |
| `distance` | `gridDistance` | Grid distance between cells |
| `line` | `gridPathCells` | Path of cells between two cells |
| `line_size` | `gridPathCellsSize` | Number of cells in path |
| `max_kring_size` | `maxGridDiskSize` | Max cells in a disk |
| `max_grid_ring_size` | `maxGridRingSize` | Max cells in a ring |

### Hierarchy

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `parent` | `cellToParent` | Get parent cell |
| `children` | `cellToChildren` | Get child cells |
| `max_children` | `cellToChildrenSize` | Max number of children |
| `center_child` | `cellToCenterChild` | Get center child cell |
| `cell_to_child_pos` | `cellToChildPos` | Position of child within parent |
| `child_pos_to_cell` | `childPosToCell` | Child cell from position |
| `compact` | `compactCells` | Compact a cell set |
| `uncompact` | `uncompactCells` | Uncompact a cell set |
| `max_uncompact_size` | `uncompactCellsSize` | Max cells after uncompaction |

### Directed Edges

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `are_neighbor_cells` | `areNeighborCells` | Check if cells are neighbors |
| `cells_to_directed_edge` | `cellsToDirectedEdge` | Get edge between neighbors |
| `valid_directed_edge?` | `isValidDirectedEdge` | Check if edge is valid |
| `directed_edge_origin` | `getDirectedEdgeOrigin` | Get origin cell of edge |
| `directed_edge_destination` | `getDirectedEdgeDestination` | Get destination cell |
| `directed_edge_to_cells` | `directedEdgeToCells` | Get both cells of an edge |
| `origin_to_directed_edges` | `originToDirectedEdges` | All edges from a cell |
| `directed_edge_to_boundary` | `directedEdgeToBoundary` | Get edge boundary coords |
| `exact_edge_length_rads` | `edgeLengthRads` | Edge length in radians |
| `exact_edge_length_km` | `edgeLengthKm` | Edge length in km |
| `exact_edge_length_m` | `edgeLengthM` | Edge length in metres |

### Vertex

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `cell_to_vertex` | `cellToVertex` | Get vertex index |
| `cell_to_vertexes` | `cellToVertexes` | Get all vertex indexes |
| `vertex_to_lat_lng` | `vertexToLatLng` | Get vertex coordinates |
| `valid_vertex?` | `isValidVertex` | Check if vertex is valid |

### Local IJ Coordinates

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `cell_to_local_ij` | `cellToLocalIj` | Cell to local IJ coords |
| `local_ij_to_cell` | `localIjToCell` | Local IJ coords to cell |

### Polygon / Region

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `polygon_to_cells` | `polygonToCells` | Fill polygon with cells |
| `max_polygon_to_cells_size` | `maxPolygonToCellsSize` | Max cells for polygon fill |
| `cells_to_multi_polygon` | `cellsToLinkedMultiPolygon` | Cells to polygon boundaries |

### Measurements & Utilities

| Method | H3 Function | Description |
|--------|-------------|-------------|
| `cell_area_rads2` | `cellAreaRads2` | Exact cell area (radians) |
| `cell_area_km2` | `cellAreaKm2` | Exact cell area (km²) |
| `cell_area_m2` | `cellAreaM2` | Exact cell area (m²) |
| `great_circle_distance_rads` | `greatCircleDistanceRads` | Distance (radians) |
| `great_circle_distance_km` | `greatCircleDistanceKm` | Distance (km) |
| `great_circle_distance_m` | `greatCircleDistanceM` | Distance (metres) |
| `hex_area_km2` | `getHexagonAreaAvgKm2` | Avg hex area at resolution |
| `hex_area_m2` | `getHexagonAreaAvgM2` | Avg hex area at resolution |
| `edge_length_km` | `getHexagonEdgeLengthAvgKm` | Avg edge length at resolution |
| `edge_length_m` | `getHexagonEdgeLengthAvgM` | Avg edge length at resolution |
| `hexagon_count` | `getNumCells` | Total cells at resolution |
| `base_cells` | `getRes0Cells` | All 122 base cells |
| `pentagons` | `getPentagons` | Pentagon cells at resolution |
| `degs_to_rads` | `degsToRads` | Degrees to radians |
| `rads_to_degs` | `radsToDegs` | Radians to degrees |
| `describe_h3_error` | `describeH3Error` | Error code description |
| `get_index_digit` | `getIndexDigit` | Direction digit at resolution |

## GeoJSON Integration (Optional)

For projects that work with GeoJSON data, an optional integration with the [geocrystal/geojson](https://github.com/geocrystal/geojson) shard is available.

```crystal
require "h3_crystal/h3/geojson"

# Fill a GeoJSON Polygon with H3 cells
polygon = GeoJSON::Polygon.new([
  [[-122.4089866, 37.813318], [-122.3805436, 37.7866302],
   [-122.3544736, 37.7198061], [-122.5123436, 37.7076131],
   [-122.4089866, 37.813318]]
])
cells = H3.polygon_to_cells(polygon, 9)

# Fill a GeoJSON MultiPolygon
multi = GeoJSON::MultiPolygon.new([polygon1, polygon2])
cells = H3.polygon_to_cells(multi, 9)

# Convert cells back to GeoJSON
multi_polygon = H3.cells_to_geojson_multi_polygon(cells)
multi_polygon.to_json # => valid GeoJSON
```

The `geojson` shard is listed as a dependency. Consumers must explicitly `require "h3_crystal/h3/geojson"` to activate the integration.

## Development

```bash
mise install                      # Install Crystal version from .mise.toml
shards install                    # Install deps + build C library
crystal spec --verbose            # Run all tests
crystal tool format --check       # Check formatting
```

## Contributing

1. Fork it (<https://github.com/swilk19/h3_crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [swilkins](https://github.com/swilk19) - creator and maintainer

## Special Thanks
- [H3 Ruby](https://github.com/StuartApp/h3_ruby)
