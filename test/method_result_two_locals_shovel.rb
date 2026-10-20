# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# A method's answer taken into two locals, one of them the receiver of
# `<<` or `[]=`, keeps its own type in both. While the method's types were
# still open, the call was read as a String mutation, and the other local
# was typed a String, so the C build failed. Through an Integer shift of
# getbyte's answer (an Integer, or nil past the end) and of Integer
# arithmetic on an ivar, and through an Array's push and element store.

class Reader
  def initialize(bytes)
    @bytes = bytes
    @pos = 0
  end

  def u8
    v = @bytes.getbyte(@pos)
    @pos += 1
    v
  end

  def u16
    hi = u8
    lo = u8
    (hi << 8) | lo
  end

  def u32
    hi = u16
    lo = u16
    (hi << 16) | lo
  end

  def u64
    hi = u32
    lo = u32
    (hi << 32) | lo
  end

  def at(i)
    v = @bytes.getbyte(i)
    v
  end

  def pair(i)
    hi = at(i)
    lo = at(i + 1)
    hi << 8
    lo + 1
  end
end

class Odometer
  def initialize(km)
    @km = km
  end

  def tick
    v = @km + 1
    @km = v
    v
  end

  def wide
    hi = tick
    lo = tick
    (hi << 32) + lo
  end
end

class Line
  def initialize(stops)
    @stops = stops
  end

  def stops
    v = @stops.dup
    v
  end

  def trip(to)
    out = stops
    out << to
    back = stops
    [out, back.reverse]
  end

  def reversed
    v = @stops.reverse
    v
  end

  def detour(via)
    out = reversed
    out[0] = via
    back = reversed
    [out, back]
  end
end

def be(v, n) = (0...n).map { |i| (v >> (8 * (n - 1 - i))) & 0xff }

rows = [["Jayang", 2729, 41_250, 3_000_000_000_123],
        ["Kondae", 212, 98_400, 7_516_192_768],
        ["Achasan", 545, 17_800, 4_294_967_297]]
rows.each do |name, code, riders, cards|
  r = Reader.new((be(code, 2) + be(riders, 4) + be(cards, 8)).pack("C*"))
  puts "#{name}: #{r.u16} #{r.u32} #{r.u64}"
end

g = Reader.new([0x47, 0x4d, 0x50].pack("C*"))
p g.pair(0)
p g.pair(1)
begin
  g.pair(2)
rescue NoMethodError => e
  puts e.class
end

o = Odometer.new(1_000)
p o.wide
p o.wide

p Line.new(["Jayang", "Guui"]).trip("Children's Grand Park")
p Line.new(["Seongsu", "Kondae"]).detour("Achasan")
