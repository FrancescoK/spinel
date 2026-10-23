# String#to_sym finds a name through hash indexes (a compile-time one for the
# program's own Symbols, a growing one for the Symbols made at run time).
# Every name must still be one Symbol, whichever way it is reached.

# static Symbols: names the program spells as literals
puts "alpha".to_sym == :alpha
puts "beta".to_sym.equal?(:beta)
puts ["gamma", "delta"].map(&:to_sym).inspect
puts "".to_sym.inspect
puts "a\0b".to_sym == :"a\0b"
puts "a\0b".to_sym == "a".to_sym
puts :"a\0b".to_s.bytesize
# a name built at run time that equals a static one is the static Symbol
puts ("al" + "pha").to_sym.equal?(:alpha)
puts ("gam" + "ma").to_sym == :gamma

# many run-time Symbols: past the index's first size (32 entries) and the
# pool's first block (8192), several times over
N = 20000
syms = []
i = 0
while i < N
  syms << "dyn_#{i}".to_sym
  i += 1
end
ok = true
i = 0
while i < N
  s = "dyn_#{i}".to_sym
  ok = false unless s == syms[i]
  ok = false unless s.to_s == "dyn_#{i}"
  ok = false unless s.to_s.to_sym == s
  ok = false unless s.inspect == ":dyn_#{i}"
  i += 1
end
puts ok
puts syms.uniq.size
puts syms[12345].inspect
puts syms[0] == syms[1]
puts ("dyn_" + "7").to_sym == syms[7]
puts ("dyn_" + "7").to_sym == syms[8]
puts ("dyn_" + "19999").to_sym.equal?(:dyn_19999)
puts :dyn_42 == syms[42]

# to_proc on Symbols reached through to_sym
words = ["x", "yy", "zzz"]
m = ("up" + "case").to_sym
puts m == :upcase
puts words.map(&m).inspect
puts m.to_proc.call("abc")
puts words.map(&"reverse".to_sym).inspect

# Symbols made at run time as Hash keys
h = {}
i = 0
while i < 100
  h["key#{i}".to_sym] = i
  i += 1
end
puts h["key42".to_sym]
puts h[:key99]
puts h.size

# Threads interning the same new names at once: one Symbol per name
threads = []
t = 0
while t < 4
  threads << Thread.new(t) do |k|
    out = []
    j = 0
    while j < 3000
      out << "thr_#{(j * 7 + k) % 3000}".to_sym
      j += 1
    end
    out
  end
  t += 1
end
all = threads.map(&:value)
flat = all.flatten
puts flat.size
puts flat.uniq.size
same = true
j = 0
while j < 3000
  s = "thr_#{j}".to_sym
  same = false unless s.to_s == "thr_#{j}"
  j += 1
end
puts same
puts all[0][0] == "thr_0".to_sym
puts all[3][0] == "thr_3".to_sym
puts all[1][5] == all[2][5]
