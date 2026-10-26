# racc's runtime with its C parser core (racc/cparse, compiled from the gem's
# source by the C extension layer): the calculator grammar of calc/calc.y,
# built by `racc -o calc_parser.rb calc.y`, through do_parse and yyparse.
require "racc/parser"
require_relative "calc/calc_parser"

p Racc::Parser::Racc_Runtime_Type
p Racc::Parser::Racc_Runtime_Core_Version_C
c = Calc.new
p c.parse("1 + 2 * 3")
p c.parse("(1 + 2) * 3 - -4")
p c.parse("10 / 3")
p c.parse("2 * (3 + 4) * 5 - 6 / 2")
begin
  c.parse("1 +")
rescue Racc::ParseError => e
  p e.class
  puts e.message
end
begin
  c.parse("1 2")
rescue Racc::ParseError => e
  p e.class
end
p c.parse("42")

class Lexed < Calc
  def tokens(str)
    @q = []
    str.scan(/\d+|\S/) { |t| @q << (t =~ /\d/ ? [:NUMBER, t.to_i] : [t, t]) }
    @q << [false, "$end"]
    @q
  end
  def each_token
    @q.each { |t| yield t }
  end
  def parse_yy(str)
    tokens(str)
    yyparse(self, :each_token)
  end
end
p Lexed.new.parse_yy("7 * (2 + 3)")
