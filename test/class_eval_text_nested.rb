# A class_eval of known text among the statements of a class_eval's text is
# grafted too, in the frame that text makes: it reads the body's locals and
# the outer text's own.
class K
  class_eval "class_eval \"def n = 1\""
  class_eval "y = 2; class_eval \"def m = 3\""
  t = 7
  class_eval "t2 = t + 1; class_eval 'T3 = t2 + t'"
  p defined?(t2)
end
p K.new.n, K.new.m, K::T3
