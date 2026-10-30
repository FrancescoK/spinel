# `__FILE__` in the text of a class_eval answers the path it is given, or
# "(eval at FILE:LINE)" of the call, as CRuby's eval does; a class_eval in
# that text answers the outer eval's path.
class K
  class_eval "def f = __FILE__"
  class_eval "def g = __FILE__", "gen.rb", 10
  class_eval "def h = __FILE__", __FILE__, __LINE__
  class_eval "class_eval \"def i = __FILE__\""
end
k = K.new
p File.basename(k.f.sub(/\A\(eval at (.*):\d+\)\z/, '\1')), k.f.end_with?(":5)"), k.g
p File.basename(k.h)
p k.i.start_with?("(eval at (eval at "), k.i.end_with?(":8):1)")
