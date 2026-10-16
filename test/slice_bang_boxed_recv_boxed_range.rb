# `@bytes.slice!(@pos..)` with @bytes an Array or a String and @pos an
# Integer or a Float: the Range is boxed beside the boxed receiver, and an
# Integer Range under the Array and String arms that index with it. The
# arms read it boxed, so the Array arm took Array#slice!(index), and the C
# did not build.
class Tape
  def initialize(bytes, pos, stop)
    @bytes = bytes
    @pos = pos
    @stop = stop
  end

  def rewind
    @pos = 0.5
    @stop = 0.5
  end

  def endless = @bytes.slice!(@pos..)
  def closed = @bytes.slice!(@pos..@stop)
  def exclusive = @bytes.slice!(@pos...@stop)
  def endless_excl = @bytes.slice!(@pos...)
  def beginless = @bytes.slice!(..@stop)
  def parenthesized = @bytes.slice!((@pos..))
  def bytes = @bytes
end

[[1, 2, 3, 4, 5], "abcde".dup].each do |v|
  %i[endless closed exclusive endless_excl beginless parenthesized].each do |m|
    t = Tape.new(v.dup, 1, 3)
    p [m, t.send(m), t.bytes]
  end
end
