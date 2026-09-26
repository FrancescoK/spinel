# A proc literal that reaches its call through a POLY slot -- a keyword
# argument, an ivar that may hold nil or a Formatter object, a `||=`
# default -- has no call site the inference can link its parameters to. The
# parameters were left untyped and emitted as integers, so a String argument
# arrived as its raw pointer and a Symbol as its id (`Logger.new(io,
# formatter: proc { |sev, time, prog, msg| ... })` printed numbers). An
# unlinked parameter is boxed: the call hands boxed values anyway.
class Sink
  attr_accessor :formatter
  def initialize(formatter: nil) = @formatter = formatter
  def emit(sev, msg)
    f = @formatter
    f.nil? ? "#{sev}|#{msg}" : f.call(sev, msg)
  end
end
p Sink.new.emit("INFO", "plain")
p Sink.new(formatter: proc { |s, m| "#{s}:#{m}" }).emit("INFO", "kw")
p Sink.new(formatter: lambda { |s, m| "#{s}=#{m.upcase}" }).emit("WARN", "lam")
k = Sink.new
k.formatter = proc { |s, m| [s.downcase, m.size] }
p k.emit("ERROR", "assigned")

def fetch(key, &blk)
  blk ||= proc { |x| "default #{x}" }
  blk.call(key)
end
p fetch(:k)
p fetch("s")
p fetch(7) { |x| "given #{x}" }

def pick(list) = list.first
g = pick([proc { |a, b| "#{a}-#{b}" }, nil])
p g.call(:x, "y")
