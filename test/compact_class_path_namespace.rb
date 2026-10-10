# A class or module defined by a path, `class A::B`, is B in A: its name
# is A::B, and a class in its body is A::B::C, which a leaf name another
# namespace also defines (Net::HTTP) does not take (#8369).
module Net
  class HTTP
    def initialize(a) = @a = a
  end
end
module WebPush; end
module Other
  class Connections
    def who = :other
  end
end
class WebPush::Connections
  def who = :webpush
  class Inner
    def who = :inner
  end
  module Stages
    attr_reader :stage
  end
  class HTTP < Net::HTTP
    include WebPush::Connections::Stages
  end
  class HTTPX < Net::HTTP
  end
  def check(x) = x.is_a?(::WebPush::Connections::HTTP)
end
module A
  module B; end
end
class A::B::C
  def who = :abc
end
p WebPush::Connections.new.who, Other::Connections.new.who, WebPush::Connections::Inner.new.who
p WebPush::Connections.name, Other::Connections.name, WebPush::Connections::Inner.name
p A::B::C.new.who, A::B::C.name
module WebPush
  p Connections.new.who
end
h = WebPush::Connections::HTTP.new(1)
p h.class.name, h.stage, WebPush::Connections.new.check(h)
p WebPush::Connections::HTTPX.new(2).class.name
p Net::HTTP.new(3).class.name
