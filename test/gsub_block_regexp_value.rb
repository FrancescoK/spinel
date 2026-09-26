# The block forms of gsub / sub (and the bang forms) with a Regexp VALUE as
# the pattern -- a parameter, a reader, a local -- rather than a literal: a
# Regexp is the compiled pattern at C level, so the scan loop takes it the
# way it takes a literal's. Before, only a literal (or a local that held
# one) was admitted; anything else was emitted as a static NoMethodError,
# and a bang form with a block parameter mistyped that parameter.
class Rules
  def initialize
    @acronyms = /(?<=([A-Za-z\d]))(HTML|XML)(?=\b|[^a-z])/
    @boundary = /(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/
  end
  def acronyms = @acronyms
  def boundary = @boundary
end
def underscore(camel, rules)
  word = camel.to_s.gsub("::", "/")
  word.gsub!(rules.acronyms) { "#{$1 && '_'}#{$2.downcase}" }
  word.gsub!(rules.boundary) { "_" }
  word.tr!("-", "_")
  word.downcase!
  word
end
r = Rules.new
p underscore("SpinelCompiler", r), underscore("Net::HTMLParser", r), underscore("XMLRoot", r)
def shout(w, re) = w.gsub(re) { |m| m.upcase }
def first(w, re) = w.sub(re) { |m| "<#{m}>" }
p shout("hello world", /o/), first("hello world", /l+/)
def caps(w, re) = w.gsub(re) { "#{$1}-#{$2}" }
p caps("ab cd", /(\w)(\w)/)
s = +"axbxc"
re = /x/
s.gsub!(re) { |m| m.upcase }
p s
t = +"one two"
t.sub!(/(\w+)/) { |m| m.reverse }
p t
def bang(w, re)
  w.gsub!(re) { |m| m * 2 }
  w
end
p bang(+"a1b2", /\d/)
