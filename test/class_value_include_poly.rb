# Module#include? on a Class value held boxed (read out of an Array) answers
# as on a constant: the class's ancestors, a subclass's through its parent,
# a struct builder's block, a builtin's modules, and a TypeError for a Class
# argument; a class's own `self.include?` still answers for it
module M; end
module N; end
class Foo; include M; end
class Bar < Foo; end
S = Struct.new(:a) { include N }
ks = [Foo, Bar, S, M, Integer, 1]
ks.each { |k| p [k.include?(M), k.include?(N), k.include?(Comparable)] unless k == 1 }
k = [Foo, 1][0]
p k.include?(M)
p [Foo][0].include?(M), [S][0].include?(N)
begin
  k.include?(Foo)
rescue TypeError => e
  p e.message
end
class Own; def self.include?(m) = :own; end
os = [Own, Foo, 2]
p os[0].include?(M), os[1].include?(M)
