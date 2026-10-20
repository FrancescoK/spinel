# A String instance variable that no write has set yet is nil: a call on it
# whose arguments run code raises nil's NoMethodError once they have run, as
# CRuby runs a call's arguments ahead of the missing method, and match? with
# a String pattern that is no valid Regexp raises the NoMethodError rather
# than the pattern's RegexpError. Set to a String, each call answers for it.

$log = []
$tries = 0
def note(s, v = s) = ($log << s; v)
DAE = /dae/

class Station
  def initialize(name, known) = (@name = name if known)
  def match_at = @name.match?(/dae/, (note("pos"); 2))
  def match_value_at = @name.match?(note("pattern", DAE), (note("pos"); 2))
  def match_counted = @name.match?(note("pattern", DAE), ($tries += 1))
  def match_text(s) = @name.match?("#{note(s)}")
  def legs = @name.each_line("#{note(" ")}").to_a
  def legs_chomped = @name.each_line(chomp: (note("chomp"); true)).to_a
  def head = @name.slice((note("from"); 0)..(note("to"); 5))
  def first = @name.slice((note("at"); 1))
  def piece = @name.slice((note("at"); 0), (note("len"); 5))
  def tag = @name.unpack1("#{note("a3")}")
  def byte = @name.unpack1("C", offset: (note("offset"); 1))
end

def show(label)
  r = begin
    yield.inspect
  rescue NoMethodError => e
    "NoMethodError #{e.message}"
  rescue RegexpError
    "RegexpError"
  end
  puts "#{label}: #{$log.join(" ")} -> #{r}"
  $log.clear
end

def report(label, s)
  show("#{label} match?(/re/, pos)") { s.match_at }
  show("#{label} match?(re, pos)") { s.match_value_at }
  show("#{label} match?(re, $tries += 1)") { s.match_counted }
  puts "tries: #{$tries}"
  show("#{label} match?(\"dae\")") { s.match_text("dae") }
  show("#{label} match?(\"[\")") { s.match_text("[") }
  show("#{label} each_line(sep)") { s.legs }
  show("#{label} each_line(chomp:)") { s.legs_chomped }
  show("#{label} slice(range)") { s.head }
  show("#{label} slice(i)") { s.first }
  show("#{label} slice(i, n)") { s.piece }
  show("#{label} unpack1(fmt)") { s.tag }
  show("#{label} unpack1(offset:)") { s.byte }
end

report("Kondae", Station.new("Kondae station", true))
report("Jayang", Station.new("Jayang station", false))
