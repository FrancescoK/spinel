# A scan block that reads Regexp.last_match sees each turn's match, as one
# that reads $~ does, with a literal pattern and with a Regexp built at run
# time (an interpolated one, or one a local holds).
TYPE = /(?<type>[sd])/
SEQ = /%#{TYPE}/
LIT = /%[sd]/

src = "value %s (%d)"
src.scan(LIT) { m = Regexp.last_match; p [m[0], m.begin(0), m.end(0)] }
src.scan(SEQ) { m = Regexp.last_match; p [m[0], m.begin(0), m[:type]] }
pat = SEQ
src.scan(pat) { p [$~[0], $~.begin(0)] }

found = []
src.scan(SEQ) { found << Regexp.last_match }
p found.map { |m| m.begin(0) }

class Seqs
  def initialize(source) = @source = source

  def parse
    out = []
    @source.scan(SEQ) { out << [Regexp.last_match.begin(0), Regexp.last_match[:type]] }
    out
  end
end
p Seqs.new("a %d b %s c %s").parse

boxed = ["x %s y %d", 1][ARGV.size]
boxed.scan(LIT) { p Regexp.last_match.begin(0) }
