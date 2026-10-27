# A `&.` index by a Range literal whose ends run code runs each end once.

def at(i)
  puts "at #{i}"
  i
end

class Holder
  def initialize
    @s = "abcdef"
  end

  def run
    p @s&.slice(at(1)..at(3))
    p @s&.[](at(1)...at(3))
  end
end
Holder.new.run

s = "abcdef"
s = nil if ARGV.size > 5
p s&.slice(at(1)..at(3))
p s&.slice(at(1)...at(3))
p s&.slice(at(1)..)
p s&.slice(..at(3))
p s&.[](at(1)..at(3))
p s&.slice((at(1)..at(3)))
p s&.slice(at(1.5)..at(3.5))
t = s.dup
p t&.slice!(at(1)..at(3))
p t
n = [nil, "q"][ARGV.size]
p n&.slice(at(1)..at(3))
a = [1, 2, 3, 4, 5]
a = nil if ARGV.size > 5
p a&.slice(at(1)..at(3))
p s[at(1)..at(3)]
