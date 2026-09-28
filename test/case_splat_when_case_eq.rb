# In a case value, `when *list` matches an element that === the subject: a
# Class its instances, a Regexp a String, a Range its members; and, as
# before, an element the subject equals.
class P; end
class Q; end
class Ver
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(o) = n <=> (o.is_a?(Ver) ? o.n : o)
end
x = P.new
klasses = [Q, P]
p(case x; when *klasses then :hit; else :miss; end)
p(case x; when String, *[P] then :mixed; else :no; end)
p(case "abc"; when *[/z/, /b/] then :re; else :no; end)
p(case 5; when *[1..3, 4..6] then :range; else :no; end)
p(case 7; when *[1, 7] then :val; else :no; end)
p(case "s"; when *["t", "s"] then :str; else :no; end)
p(case :k; when *[] then :empty; else :no; end)
p(case Class; when *[Class] then :cls; else :no; end)
p(case Ver.new(2); when *[1, 2] then :ver; else :no; end)
