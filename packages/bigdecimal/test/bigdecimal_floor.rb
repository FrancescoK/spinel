# BigDecimal#floor, #ceil and #truncate: no argument answers an Integer, n
# answers a BigDecimal. Magnitudes below one included, for either sign.
require "bigdecimal"

["12.345", "-12.345", "0.3", "-0.3", "7", "-7", "0.0123", "0"].each do |s|
  b = BigDecimal(s)
  p [b.floor, b.ceil, b.truncate]
  p [b.floor.class, b.ceil.class, b.truncate.class]
end

["12.345", "-12.345", "123.456"].each do |s|
  b = BigDecimal(s)
  [2, 1, 0, -1].each do |n|
    p [b.floor(n), b.ceil(n), b.truncate(n)]
  end
end

p (BigDecimal("0.0123") * 65535).floor
p [65535 - (BigDecimal("0.5") * 65535).floor].pack("n").bytes

# The place count as CRuby reads it: to_int, a truncated Float, and a
# TypeError for nil or a String, on a zero receiver too.
class Places
  def to_int = 1
end
p [BigDecimal("12.345").floor(Places.new), BigDecimal("12.345").ceil(1.9), BigDecimal("12.345").round(Places.new)]
[nil, "1"].each do |bad|
  ["0", "12.345"].each do |s|
    begin
      BigDecimal(s).floor(bad)
      p :no_error
    rescue TypeError => e
      p e.message
    end
  end
end

# to_int must answer an Integer, as CRuby's conversion checks.
class BadPlaces
  def to_int = "1"
end
["0", "12.345"].each do |s|
  begin
    BigDecimal(s).floor(BadPlaces.new)
    p :no_error
  rescue TypeError => e
    p e.message
  end
end
