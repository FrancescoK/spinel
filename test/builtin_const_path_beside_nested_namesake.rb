# A path to US_ASCII through Encoding names the builtin's constant though the
# program nests a module of its own named Encoding elsewhere
# (AS::JSON::Encoding); only a path written inside that namespace names the
# nested one. Any nested Encoding made every such path a lookup by the last
# name, which found the program's own US_ASCII: the constant read itself
# before it was set, and other reads got nil.

module AS
  module JSON
    module Encoding
      U2028 = "u2028"
    end
    LINE_SEP = Encoding::U2028
    class Coder
      def self.sep = Encoding::U2028
    end
  end
end

class Foo
  class Encoding
    BINARY = 7
  end
  def self.binary = Encoding::BINARY
end

module Mime
  class UriEncoder
    US_ASCII = Encoding::US_ASCII
    UTF_8 = Encoding::UTF_8
  end
end

def ascii_name = Encoding::US_ASCII.to_s

p Mime::UriEncoder::US_ASCII.to_s
p Mime::UriEncoder::UTF_8.to_s
p ascii_name
p Encoding::BINARY.to_s
p AS::JSON::LINE_SEP
p AS::JSON::Coder.sep
p Foo.binary
