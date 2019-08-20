require "./lib_h3"
require "./types"

module H3
  module Bindings
    module Base
      extend self
      # Base for Bindings.
      #
      # When extended, this module sets up the class to use the H3 C library.
      include Types
      # test = Resolution.new(5)
      # puts "Test: #{test}"
    end
  end  
end

