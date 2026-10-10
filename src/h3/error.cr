require "./bindings/lib_h3"

module H3
  # Base class for all errors raised by this library.
  #
  # Wraps an `H3Error` code returned by the H3 C library. `code` is always the
  # raw value; `error_code` is nil when the code is not a known `ErrorCode`.
  class Error < Exception
    getter code : UInt32
    getter error_code : ErrorCode?

    def initialize(@code : UInt32, message : String? = nil)
      @error_code = ErrorCode.from_value?(@code)
      super(message)
    end
  end

  # H3 error codes 1-19 (`E_SUCCESS` is not an error). Names are the H3 C
  # constants without the `E_` prefix, in CamelCase.
  enum ErrorCode : UInt32
    Failed           =  1
    Domain           =  2
    LatlngDomain     =  3
    ResDomain        =  4
    CellInvalid      =  5
    DirEdgeInvalid   =  6
    UndirEdgeInvalid =  7
    VertexInvalid    =  8
    Pentagon         =  9
    DuplicateInput   = 10
    NotNeighbors     = 11
    ResMismatch      = 12
    MemoryAlloc      = 13
    MemoryBounds     = 14
    OptionInvalid    = 15
    IndexInvalid     = 16
    BaseCellDomain   = 17
    DigitDomain      = 18
    DeletedDigit     = 19
  end

  # One subclass per `ErrorCode`, e.g. `PentagonError`, `CellInvalidError`.
  # Each can be built from just a message; the code is filled in.
  {% for member in ErrorCode.constants %}
    class {{member}}Error < Error
      def initialize(message : String? = nil)
        super(ErrorCode::{{member}}.value, message)
      end
    end
  {% end %}

  class Error
    # Raises the `Error` subclass matching `err`; does nothing when `err` is 0.
    #
    # The message is `"<context>: <describe_h3_error text> (code N)"`. Unknown
    # codes raise the base `H3::Error` with the raw code preserved.
    def self.check!(err : UInt32, context : String) : Nil
      return if err == 0
      message = "#{context}: #{String.new(Bindings::Private::LibH3.describe_h3_error(err))} (code #{err})"
      {% begin %}
        case ErrorCode.from_value?(err)
        {% for member in ErrorCode.constants %}
        when ErrorCode::{{member}} then raise {{member}}Error.new(message)
        {% end %}
        else
          raise Error.new(err, message)
        end
      {% end %}
    end
  end
end
