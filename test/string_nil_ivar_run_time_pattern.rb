# A String instance variable that no write has set yet is nil: [], slice,
# split, partition, rpartition and start_with? with a pattern that is a
# Regexp or a String only at run time raise nil's NoMethodError, as CRuby
# does, once the pattern has been evaluated. One set to a String answers
# for it.

PATTERNS = ["Kon", /d(a)e/, " "]

class Station
  def initialize(name, known) = (@name = name if known)
  def at(pat) = @name[pat]
  def capture(pat, n) = @name[pat, n]
  def piece(pat) = @name.slice(pat)
  def words(pat) = @name.split(pat)
  def first_part(pat) = @name.partition(pat)
  def last_part(pat) = @name.rpartition(pat)
  def starts?(pat) = @name.start_with?(pat)
end

def pattern(i)
  print "(pattern #{i}) "
  PATTERNS[i]
end

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError #{e.message}"
end

def report(label, s)
  show("#{label} [String]") { s.at(pattern(0)) }
  show("#{label} [Regexp]") { s.at(pattern(1)) }
  show("#{label} [Regexp, 1]") { s.capture(pattern(1), 1) }
  show("#{label} slice(String)") { s.piece(pattern(0)) }
  show("#{label} slice(Regexp)") { s.piece(pattern(1)) }
  show("#{label} split(String)") { s.words(pattern(2)) }
  show("#{label} split(Regexp)") { s.words(pattern(1)) }
  show("#{label} partition(String)") { s.first_part(pattern(2)) }
  show("#{label} partition(Regexp)") { s.first_part(pattern(1)) }
  show("#{label} rpartition(String)") { s.last_part(pattern(2)) }
  show("#{label} start_with?(String)") { s.starts?(pattern(0)) }
  show("#{label} start_with?(Regexp)") { s.starts?(pattern(1)) }
end

report("Kondae", Station.new("Kondae station", true))
report("Achasan", Station.new("Achasan station", false))
