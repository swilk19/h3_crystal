require "./bindings/base"

module Inspection
  include H3::Bindings::Base

  H3_TO_STR_BUF_SIZE = 17

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
  def resolution(h3_index : UInt64) : Int32
    LibH3.resolution(h3_index)
  end

  # @!method base_cell(h3_index)
  #
  # Derives the base cell number of the given H3 index
  #
  # @param [Integer] h3_index A valid H3 index
  #
  # @example Derive the base cell number of a H3 index
  #   H3.base_cell(617700440100569087)
  #   20
  #
  # @return [Integer] Base cell number
  def base_cell(h3_index : UInt64) : Int
    LibH3.base_cell(h3_index)
  end

  # @!method from_string(h3_string)
  #
  # Derives the H3 index for a given hexadecimal string representation.
  #
  # @param [String] h3_string A H3 index in hexadecimal form.
  #
  # @example Derive the H3 index from the given hexadecimal form.
  #   H3.from_string("8928308280fffff")
  #   617700169958293503
  #
  # @return [Integer] H3 index
  def from_string(h3_string : String) : UInt64
    LibH3.from_string(h3_string)
  end

  # @!method pentagon?(h3_index)
  #
  # Determine whether the given H3 index is a pentagon.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Check if H3 index is a pentagon
  #   H3.pentagon?(585961082523222015)
  #   true
  #
  # @return [Boolean] True if the H3 index is a pentagon.
  def pentagon?(h3_index : UInt64) : Bool
    LibH3.pentagon?(h3_index)
  end

  # @!method class_3_resolution?(h3_index)
  #
  # Determine whether the given H3 index has a resolution with
  # Class III orientation.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Check if H3 index has a class III resolution.
  #   H3.class_3_resolution?(599686042433355775)
  #   true
  #
  # @return [Boolean] True if the H3 index has a class III resolution.
  def class_3_resolution?(h3_index : UInt64) : Bool
    LibH3.class_3_resolution?(h3_index)
  end

  # @!method valid?(h3_index)
  #
  # Determine whether the given H3 index is valid.
  #
  # @param [Integer] h3_index A H3 index.
  #
  # @example Check if H3 index is valid
  #   H3.valid?(599686042433355775)
  #   true
  #
  # @return [Boolean] True if the H3 index is valid.
  def valid?(h3_index : UInt64) : Bool
    LibH3.valid?(h3_index)
  end

  # Derives the hexadecimal string representation for a given H3 index.
  #
  # @param [Integer] h3_index A valid H3 index.
  #
  # @example Derive the given hexadecimal form for the H3 index
  #   H3.to_string(617700169958293503)
  #   "89283470dcbffff"
  #
  # @return [String] H3 index in hexadecimal form.
  def to_string(h3_index : UInt64) : String
    h3_str = Pointer(LibC::Char).malloc(H3_TO_STR_BUF_SIZE)
    LibH3.h3_to_string(h3_index, h3_str, H3_TO_STR_BUF_SIZE)
    String.new(h3_str)
  end

  # @!method max_face_count(h3_index)
  #
  # Returns the maximum number of icosahedron faces the given H3 index may intersect.
  #
  # @param [Integer] h3_index A H3 index.
  #
  # @example Check maximum faces
  #   H3.max_face_count(585961082523222015)
  #   5
  #
  # @return [Integer] Maximum possible number of faces
  def max_face_count(h3_index : UInt64) : Int32
    LibH3.max_face_count(h3_index)
  end

  # @!method faces(h3_index)
  #
  # Find all icosahedron faces intersected by a given H3 index.
  #
  # @param [Integer] h3_index A H3 index.
  #
  # @example Find icosahedron faces for given index
  #   H3.faces(585961082523222015)
  #   [1, 2, 6, 7, 11]
  #
  # @return [Array<Integer>] Faces. Faces are represented as integers from 0-19, inclusive.
  def faces(h3_index : UInt64) : Array(Int32)
    max_faces = max_face_count(h3_index)
    c_output = Pointer(Int32).malloc(max_faces)
    LibH3.h3_faces(h3_index, c_output)
    result = Array(Int32).new(max_faces)
    max_faces.times do |i|
      result << c_output[i] unless c_output[i] < 0
    end
    return result.sort
  end
end
