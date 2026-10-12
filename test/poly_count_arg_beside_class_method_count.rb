# count(arg) on a receiver with no class (an attr_accessor nobody assigns) is the
# builtin arm; a `def self.count(args)` elsewhere answering a poly value made
# the analyzer type the call boxed while the arm answered a bare Integer, and
# the C did not compile (#8634). The arm boxes where the call is typed so.
module Ser
  def self.count(args)
    args.length
  end
end

class Span
  def length
    "long"
  end
end

module Store
  class << self
    attr_accessor :adapter
  end
end

class Base
  def self.count
    Store.adapter.count("posts")
  end
end

def other_count
  Store.adapter.count(Span.new)
end

p Base.count if ARGV[0]
p other_count if ARGV[1]
p 1
