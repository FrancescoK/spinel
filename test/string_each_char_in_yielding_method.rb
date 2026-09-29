# String#each_char / each_line / each_byte blocks inside a method whose
# body is inlined at a yield call site read that method's locals.
class S
  def each_char
    "xy".each_char { |ch| yield ch.upcase }
  end

  def lines
    "a\nb".each_line { |ln| yield ln.chomp }
  end

  def bytes
    "AB".each_byte { |bt| yield bt + 1 }
  end

  def count
    n = 0
    "xy".each_char { |ch| n += 1; yield ch * n }
    n
  end
end

s = S.new
s.each_char { |c| p c }
s.lines { |l| p l }
s.bytes { |b| p b }
p(s.count { |c| p c })
