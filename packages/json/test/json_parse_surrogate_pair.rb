require "json"

# A \u escape of a high surrogate has to be followed by one of a low
# surrogate, which together make one character, as CRuby's parser has it:
# with nothing after it, or another escape, it raises ParserError. A lone
# low surrogate is written as its bytes, as there. (The escapes are built
# from a backslash byte so the source holds no \u text of its own.)
def u(*hex) = hex.map { |h| 92.chr + "u" + h }.join
q = 34.chr
docs = [
  q + u("d83d", "de00") + q,
  q + u("dbff", "dfff") + q,
  q + "a" + u("d800", "dc00") + "b" + q,
  q + u("dc00") + q,
  q + u("d800") + "x" + q,
  q + u("d800") + q,
  q + u("d800", "0041") + q,
  q + u("d800") + 92.chr + "n" + q,
  q + "a" + u("d800", "d800") + q,
  q + u("dc00", "d800") + q,
  "[" + q + u("d83d", "de00") + q + ", " + q + u("d800") + q + "]"
]
docs.each do |s|
  r = begin
    v = JSON.parse(s)
    (v.is_a?(Array) ? v.join("|") : v).bytes.inspect
  rescue JSON::ParserError
    "JSON::ParserError"
  end
  puts "#{s.bytes.inspect} => #{r}"
end
