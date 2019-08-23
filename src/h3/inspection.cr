require "./bindings/base"

module Inspection
    include H3::Bindings::Base

    # @!method resolution(h3_index)
    #
    # Derive the resolution of a given H3 index
    #
    # @param [Integer] h3_index A valid H3 index
    #
    # @example Derive the resolution of a H3 index
    #   H3.resolution(617700440100569087)
    #   9
    #
    # @return [Integer] Resolution of H3 index
    # attach_function :resolution, :h3GetResolution, %i[h3_index], Resolution
end