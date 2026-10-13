# each_line on a value that may be a String or an object of a program class
# that defines each_line: the String answers itself with a block and its
# lines without one, boxed where the call is typed as any value.
class Lines
  def each_line(chomp: false)
    yield "x"
    self
  end
end

def count(source)
  n = 0
  source.each_line(chomp: true) { |line| n += 1 unless line.empty? }
  n
end

def last_seen(source)
  seen = nil
  answer = source.each_line(chomp: true) { |line| seen = line }
  [seen, answer.class]
end

def lines_of(source) = source.each_line(chomp: true).to_a

p count("a\n\nb\n")
p count(Lines.new)
p last_seen("a\nb\n")
p last_seen(Lines.new)
p lines_of("c\nd\n")
