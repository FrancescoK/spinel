# A lambda's keyword parameter binds a boxed value, and an IO handed through
# one into a class kept only its boxed form: `wait_readable` in a condition
# was refused, and the Enumerable rewrite of a call on what was read from it
# ran before the parameter had a type, so filter_map raised NoMethodError.

class Terminal
  KEYS = { "n" => :next, "q" => :quit }.freeze

  def initialize(input:)
    @input = input
  end

  def ready?
    @input.wait_readable(0.5) ? true : false
  end

  def writable?
    @input.wait_writable(0.5) ? "writable" : "blocked"
  end

  def keys
    case (got = @input.read_nonblock(64, exception: false))
    when :wait_readable then []
    when nil then [:eof]
    else got.scan(/./m).filter_map { |key| KEYS[key] }
    end
  end
end

PIPE = IO.pipe
R = PIPE[0]
W = PIPE[1]
W.write("qxn")

CONSOLE = ->(input: R) { Terminal.new(input:) }
term = CONSOLE.call
p term.ready?
p term.keys
p term.keys
W.close
p term.keys

OUT = ->(input: W) { Terminal.new(input:) }
_, w2 = IO.pipe
p OUT.call(input: w2).writable?

class Box
  def initialize(v:)
    @v = v
  end

  def keys
    @v.scan(/./m).filter_map { |k| k == "q" ? :quit : nil }
  end
end

BOX = ->(v: "qn") { Box.new(v:) }
p BOX.call.keys
