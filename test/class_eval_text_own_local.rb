# A local the text of a class_eval makes is the eval's own, as in CRuby: the
# body does not see it after, each element of a stamped-out template gets
# a fresh one, and a block in the text keeps its own locals.
class K
  class_eval "t = 3; Z = t * 2"
  p defined?(t)
  %w[a b].each do |m|
    class_eval "c ||= 0; c += 1; X#{m.upcase} = c"
  end
  class_eval "[1, 2].each { |v| u = v }; U = defined?(u).inspect"
end
p K::Z, K::XA, K::XB, K::U
