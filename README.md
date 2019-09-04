# H3 Crystal - Testing

![h3](https://user-images.githubusercontent.com/98526/50283275-48177300-044d-11e9-8337-eba8d3cc88a2.png)

![build](https://github.com/swilk19/h3_crystal/workflows/build/badge.svg)

Crystal-to-C bindings for Uber's [H3 library](https://uber.github.io/h3/).

Please consult [the H3 documentation](https://uber.github.io/h3/#/documentation/overview/introduction) for a full explanation of terminology and concepts.

## Supported H3 Versions

The semantic versioning of this shard matches the versioning of the H3 C library. E.g. version `3.5.x` of this shard is targeted for version `3.5.y` of H3 C lib where `x` and `y` are independent patch levels.

## Getting Started

Before installing the shard, please install the build dependencies for your system as instructed here: https://github.com/uber/h3#install-build-time-dependencies


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     h3_crystal:
       github: swilk19/h3_crystal
   ```

2. Run `shards install`

## Usage

```crystal
require "h3_crystal"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/h3_crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [swilkins](https://github.com/your-github-user) - creator and maintainer
