# A constant whose Integer can be nil is boxed only after inference, so a
# parameter defaulting to it and a method answering it kept a plain Integer
# slot: the default did not compile, and the answer read nil as 0 (rack's
# QueryParser, `def initialize(..., bytesize_limit: BYTESIZE_LIMIT)`).

def pick(n) = n > 0 ? n : nil

NONE = pick(0)
SOME = pick(3)

def none = NONE
def some = SOME
p none, some

def positional(x = NONE) = x
def keyword(limit: SOME) = limit
p positional, positional(5), keyword, keyword(limit: nil)

class Parser
  attr_reader :depth, :limit

  def self.make_default(depth, **options) = new(depth, **options)

  def initialize(depth, limit: NONE)
    @depth = depth
    @limit = limit
  end
end

q = Parser.make_default(32)
p q.depth, q.limit, Parser.new(1, limit: 9).limit
