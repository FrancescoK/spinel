# A nested module named after a builtin CLASS -- `module Frame; module
# JSON; module Encoding` is activesupport's ActiveSupport::JSON::Encoding
# -- names a fresh constant in CRuby. Spinel's C type for a module is its
# bare tail name, which collided with the runtime's sp_Encoding, and the
# build was refused. A nested class named like a builtin was already
# qualified out of the collision; a nested module takes the same
# qualification, and its references follow.
module Frame
  module JSON
    module Encoding
      PRECISION = 3
      def self.name_of = "frame encoding"
      def self.precise?(n) = n >= PRECISION
    end
    def self.encode(x) = "#{x}@#{Encoding::PRECISION}"
  end
  module Set
    LIMIT = 9
    def self.limit = LIMIT
  end
  class Time
    def self.zone = "utc-ish"
  end
end

p Frame::JSON::Encoding::PRECISION
p Frame::JSON::Encoding.name_of
p Frame::JSON::Encoding.precise?(4)
p Frame::JSON.encode(1)
p Frame::Set.limit
p Frame::Time.zone
p Encoding::UTF_8.to_s
p Time.at(0).utc.year
