# Stored block parameters retain the String bound by their yield or iterator.
require "tmpdir"
chars = []
"a\0b".each_char { |ch| chars << ch; ch << "x" * 100 }
p chars.map { |ch| [ch.size, ch[0]] }
lines = []
"one\ntwo\n".each_line { |line| lines << line; line << "!" }
p lines

def hand(s)
  yield s
  s
end
s = +"y"
kept = []
hand(s) { |v| kept << v; v << "z" * 100 }
p [s.size, kept[0].size]

saved = []
fn = ->(v) { saved << v; v << "q" * 100 }
a = +"p"
fn.call(a)
p [a.size, saved[0].size]

frozen_values = []
begin
  hand("frozen") { |v| frozen_values << v; v << "!" }
rescue FrozenError
  p frozen_values
end

# A user iterator sharing the name leaves a String arm in boxed dispatch.
class Chars
  def each_char
    yield "z"
  end
end
def letters(input)
  output = []
  input.each_char { |letter| output << letter }
  output
end
p letters(["ab", 1][0])
p letters([Chars.new, 1][0])
m = +"q"
m << "r"
p letters([m, 1][0])

path = File.join(Dir.tmpdir, "spinel_stored_block_#{$$}.txt")
begin
  File.write(path, "uv")
  File.open(path) { |file| p letters(file) }
ensure
  File.delete(path)
end
