# TODO: Write documentation for `H3`
# The main H3 namespace.
#
# All public methods for the library are defined here.
#
# @see https://h3geo.org/docs/
require "./h3/indexing"
require "./h3/inspection"
require "./h3/traversal"
require "./h3/hierarchy"

module H3
  VERSION = "4.4.1"

  # TODO: Put code here
  extend Indexing
  extend Inspection
  extend Traversal
  extend Hierarchy
end
