# String#scrub with a block hands it each invalid byte sequence and puts its
# answer in the sequence's place; it used to ignore the block. A sequence is
# a lead byte and the continuation bytes that fit it, as CRuby cuts them, so
# a truncated character is one and an overlong or surrogate byte run is one
# per byte, with or without a block. The answer must be a String of valid
# bytes, and a replacement argument besides the block must be nil.
def t
  yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end
s = "ab\xFFcd\xFE\xFDe"
p s.scrub { |b| "<#{b.unpack1('H*')}>" }
p s.scrub { "?" }
p s.scrub { |b| b.bytesize.to_s }
p "abc".scrub { "?" }
p "".scrub { "?" }
p "\xFF".scrub { |b| b.inspect }
p "a\xE3\x81b".scrub { |x| "<#{x.bytesize}>" }
p "a\xF0\x9F\x98b\xC0\xAFc\xED\xA0\x80".scrub { |x| "<#{x.unpack1('H*')}>" }
p "caf\xC3\xA9 \xC3".scrub { "!" }.unpack1("H*")
p s.scrub(nil) { "_" }
n = 0
p s.scrub { n += 1; n.to_s }, n
p "a\xE3\x81b".scrub("?"), "a\xE3\x81".scrub.unpack1("H*"), "a\xC0\xAFc".scrub("*")
p "a\xF0\x9F\x98b\xC0\xAFc\xED\xA0\x80".scrub("?")
t { p s.scrub("*") { "?" } }
t { p s.scrub { 1 } }
t { p s.scrub { nil } }
t { p s.scrub { |b| b } }
t { p "a\xFF".scrub("\xFE") }
p "abc".scrub("\xFE")
