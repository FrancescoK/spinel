# A method whose tail appends to, or re-encodes, the new String another
# method answers (`ymd << "T00:00:00"`, `iso(kind).force_encoding(enc)`)
# answers a new String too: a caller may change it in place. The return walk
# took such a tail as neither a new String nor a shared handle, so a caller's
# in-place change of the call's value was refused (the date package's
# rfc3339, `(to_s << 'T00:00:00+00:00').force_encoding(Encoding::US_ASCII)`,
# through DateTime#to_s -> strftime -> internal_strftime's `fast_ymd << ...`).
class Stamp
  def initialize(y) = @y = y
  def ymd = @y.to_s << "-01-01"
  def iso(kind)
    case kind
    when :date then ymd
    when :time then ymd << "T00:00:00"
    else "#{ymd}Z".force_encoding(Encoding::US_ASCII)
    end
  end
  def tagged(kind) = iso(kind).force_encoding(Encoding::US_ASCII)
  def rfc = (tagged(:time) << "+00:00").force_encoding(Encoding::US_ASCII)
end

s = Stamp.new(2001)
p s.rfc
p s.tagged(:date)
p s.tagged(:other)
r = s.rfc
r << "!"
p r
p s.rfc

# a subclass answering through the same tails
class Later < Stamp
  def ymd = "#{super}x"
end
l = Later.new(1999)
q = l.rfc
q << "?"
p q
p l.tagged(:date)
