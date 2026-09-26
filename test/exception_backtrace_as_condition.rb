# An exception's backtrace used as a condition, on a receiver narrowed by a
# `case ... when ::Exception` from a poly value (the logger gem's
# Formatter#msg2str). `backtrace` is nil for an exception never raised and
# an Array once it was; the condition emitter refused the array-valued call
# as a non-bool condition.
def msg2str(msg)
  case msg
  when ::String then msg
  when ::Exception then "#{msg.message} (#{msg.class})\n#{msg.backtrace.join("\n") if msg.backtrace}"
  else msg.inspect
  end
end
p msg2str("plain")
p msg2str(42)
p msg2str(RuntimeError.new("never raised"))
begin
  raise ArgumentError, "raised"
rescue => e
  s = msg2str(e)
  p s.lines.first.chomp
end
# nil for an exception never raised, an Array once it was: only the
# distinction is asserted -- Spinel captures no frames (docs/limitations.md)
def frames?(e) = e.backtrace ? :frames : :none
p frames?(RuntimeError.new("x"))
begin; raise "y"; rescue => f; p frames?(f); end
xs = ["s", RuntimeError.new("poly")]
p xs.map { |m| m.is_a?(Exception) && m.backtrace ? :frames : :none }
