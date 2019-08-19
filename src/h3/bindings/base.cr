require "./lib_h3"

module H3
  module Bindings
    module Base
      # Base for Bindings.
      #
      # When extended, this module sets up the class to use the H3 C library.
      alias H3Index = LibH3::H3Index
    end
  end  
end

