# A Regexp local that is always bound to one literal is compiled as that
# literal's pattern. The local was found by its name alone, so two methods
# whose locals share a name both matched with the first one's pattern, and
# a local reassigned another literal (in its scope or in a block) kept the
# first. A local is now its scope's, and resolves to a literal only when
# every write to it assigns that literal.

def a; r = /(?<n>x)y/i; p r.match?("xy", 0); end
def b; r = /a(b)?/; p r.match?("a"); end
a
b

# an instance method and a class method of one class
class C
  def self.m = (r = /x/; r.match?("x"))

  def m = (r = /y/; r.match?("x"))
end
p C.new.m, C.m

# the top level and a method
r = /y/
def tm = (r = /x/; r.match?("x"))
p r.match?("x"), tm

# two blocks, a block-local, a block that reassigns the local
[1].each { q = /x/; p q.match?("x") }
[1].each { q = /y/; p q.match?("x") }
s = /x/
1.times { |_i; s| s = /y/; p s.match?("x") }
p s.match?("x")
t = /x/
[1].each { t = /y/ }
p t.match?("x")

# reassigned in its scope, conditionally, or with ||=
u = /a/
p u.match?("a")
u = /b/
p u.match?("a")
def cond(c)
  v = /x/
  v = /(x)/ if c
  [v.match?("x"), "xx".scan(v)]
end
p cond(false), cond(true)
w = /a/
w ||= /b/
p w.match?("a")

# the arms that need a literal: index, start_with?, slice, scan, sub
def s1 = (z = /a(b)/; ["zab"[z, 1], "zab".index(z), "abz".start_with?(z), "xy".scan(z)])
def s2 = (z = /c(d)/; ["zcd"[z, 1], "zcd".index(z), "abz".start_with?(z), "cdcd".scan(z)])
def s3 = (z = /x/; ["xx".scan(z), "axb".sub(z, "-")])
p s1, s2, s3

# ivars of two classes, a parameter
class D
  def initialize = (@r = /x/)

  def t = @r.match?("x")
end
class E
  def initialize = (@r = /y/)

  def t = @r.match?("x")
end
p E.new.t, D.new.t
def pm(r = /x/) = r.match?("x")
p pm, pm(/y/)
