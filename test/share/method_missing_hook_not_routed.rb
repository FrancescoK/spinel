# A method_missing hook is never routed a call by Spinel (it warns where
# one is defined), so the String it would answer CRuby's nil.t does not
# make the String a boxed call's targets answer look shared (#9258
# cluster 8). Revisit when method_missing dispatch is taken up.
$keep = String.new("hook")
class Object
  def method_missing(name, *args) = $keep
end
class A
  def t = String.new("a")
end
class B
  def t = String.new("b")
end
o = [A.new, B.new][ARGV.length]
tk = o.t
tk << "!"
puts tk, $keep
