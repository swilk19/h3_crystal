module H3
  module Bindings
    module Types
      class Resolution
        RANGE = 0..15

        def initialize(value : Int32)
          raise("Value must be between #{RANGE.begin} and #{RANGE.end}") unless RANGE.covers?(value)
          @value = value
        end

        def value
          @value
        end

        def to_unsafe
          value
        end
      end
    end
  end
end
