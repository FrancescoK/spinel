# `x[k] = v` on a boxed receiver, with no user class owning `[]=`. A String
# receiver with a String or Regexp key lost the store (sp_poly_set_str and
# sp_poly_set_poly have no String arm), and a Symbol, which has `[]` but no
# `[]=`, took the store silently where CRuby raises NoMethodError.
def mk = [1, "x"].last

t = mk; t = +"hello" if t
t["ell"] = "ipp"
p t
t = mk; t = +"hello" if t
t[/l+/] = "L"
p t
t = mk; t = +"hello" if t
t[1] = "E"
p t
t = mk; t = +"hello" if t
begin
  t["zz"] = "q"
rescue IndexError => e
  p e.message
end
begin
  t[/z+/] = "q"
rescue IndexError => e
  p e.message
end

# one String under two names
s = +"hello"
u = nil
u ||= s
u["ell"] = "ELL"
p [s, u]

# a Hash still stores under the key
h = [1, {}].last
h["k"] = 1
p h

# receivers with no `[]=`
[5, :sym, nil, 2.5, true].each do |x|
  [0, "k", :k].each do |key|
    begin
      x[key] = 9
      p x
    rescue NoMethodError => e
      p [e.class, x]
    end
  end
end

# a boxed key: any of String#[]='s keys at run time
def boxed_key(i) = [1, "x", 1..2, /c/, -1, 0...1, nil][i]
[0, 2, 3, 4, 5].each do |i|
  q = [+"abcd", 1][0]
  k = boxed_key(i)
  q[k] = "Z"
  p q
end
k = ["k", 0][1]
q = [+"abc", 1][0]
q[k] = "0"
p q
j = ["b", 0][0]
q = [+"abc", 1][0]
q[j] = "B"
p q
a = [[1, 2, 3], 1][0]
a[boxed_key(0)] = 9
p a
h = [{ 1 => 2 }, 1][0]
h[boxed_key(0)] = 5
p h
q = [+"ab", 1][0]
begin
  q[boxed_key(0) + 4] = "x"
rescue IndexError => e
  p e
end

# a boxed Range key's span, read as CRuby reads it: an endless end to the
# last character, a Float end through to_int, and a begin outside the
# String a RangeError naming the Range
def rk(i) = [1, (0..), (1..), (..2), (-2..), (0...1.5), (1...), (0..1.5), (1..-1.5), (...-1), (5..), (-6..1), (4..), (..-10)][i]
(1..13).each do |i|
  q = [+"abcd", 1][0]
  begin
    q[rk(i)] = "Z"
    p q
  rescue RangeError => e
    p e.message
  end
end

# a key or value that rebinds the receiver changes the String read before
# it, and the new binding stays; one that mutates it in place still
# changes it, and the store lands on the change
def dupv(x) = [1, x.dup].last
s = dupv("abc"); s["b"] = (s = dupv("xyz"); "Q"); p s
s = dupv("abc"); s[(s = dupv("xyz"); "b")] = "Q"; p s
s = dupv("abc"); s[/b/] = (s = dupv("xyz"); "Q"); p s
[2, 3, 4].each do |i|
  s = dupv("abc"); s[boxed_key(i)] = (s = dupv("xyz"); "Q"); p s
end
s = dupv("abc"); s[(s = dupv("xyz"); 0)] = "Q"; p s
s = dupv("abc"); s[1] = (s = dupv("xyz"); "Q"); p s
s = dupv("abcd"); s[(s = dupv("wxyz"); 1..2)] = "Q"; p s
s = dupv("abcd"); s[(s = dupv("wxyz"); [1, 0..1].last)] = "Q"; p s
s = dupv("abc"); s[(s = [1, :sym].last; 0)] = "Q"; p s
s = dupv("abc"); s["b"] = (s = s; "Q"); p s
a = [[1, 2], 1][0]; o = a; a[(a = [7, 8]; 0)] = "x"; p [o, a]
f = [1, false].last
s = dupv("abc"); s[(s[0] = "X"; 1)] = "Y"; p s
s = dupv("abc"); s[(s << "d"; 0)] = "Q"; p s
s = dupv("abc"); s[(s = dupv("q") if f; s.upcase!; 0)] = "Q"; p s
s = dupv("abc"); s[0] = (s = dupv("q") if f; s << "d"; "Q"); p s
def through_proc(f)
  s = dupv("abc"); pr = -> { s[0] = "X"; s = dupv("q") if f; 1 }; s[pr.call] = "Y"; p s
end
through_proc(f)
a = [[1, 2, 3], 1][0]; a[(a = [5] if f; a[0] = "x"; 1)] = 9; p a
class Holder
  def initialize = (@s = [1, "abc".dup].last; @t = [1, "xyz".dup].last)
  def bump = (@s[0] = "X"; 1)
  def run
    @s["c"] = (@s = @t; "Q"); p @s
    @s = [1, "abc".dup].last; @t = [1, "xyz".dup].last
    @s[(@s = @t; "b")] = "Q"; p @s
    @s = [1, "abc".dup].last; @t = [1, "xyz".dup].last
    @s[(@s = @t; 0)] = "Q"; p @s
    @s = [1, "abc".dup].last; @s[bump] = "Y"; p @s
    @s = [1, "abc".dup].last; @s[1] = (@s[0] = "X"; "Y"); p @s
    @s = [1, "abc".dup].last; @s[/a/] = "Q"; p @s
  end
end
Holder.new.run
