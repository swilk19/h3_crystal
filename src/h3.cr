# TODO: Write documentation for `H3`
# The main H3 namespace.
#
# All public methods for the library are defined here.
#
# @see https://uber.github.io/h3/#/documentation/overview/introduction
require "./h3/indexing"
require "./h3/inspection"

module H3
  VERSION = "3.6.0"

  # TODO: Put code here
  extend Indexing
  extend Inspection
end
