# A constant PATH whose middle segment is a bundled library's class name
# (`ActiveSupport::JSON::Encoding`, here Frame::JSON::Codec) is that
# module's own constant, not the stdlib JSON. The check that tells a
# program naming JSON to `require "json"` matched the path segment by its
# bare name and refused every activesupport file reaching its JSON
# encoder; only a top-level name is the library's.
module Frame
  module JSON
    module Codec
      PRECISION = 3
      def self.name_of = "frame json"
    end
  end
  module Set
    LIMIT = 9
  end
end

p Frame::JSON::Codec::PRECISION
p Frame::JSON::Codec.name_of
p Frame::Set::LIMIT
