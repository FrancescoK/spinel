# a class with an empty body under Numeric is Comparable through Numeric:
# the class-body passes take its definition's body, empty or not
class NoBody < Numeric; end
a = NoBody.new
p a.is_a?(Comparable), NoBody.include?(Comparable)
p [a, a].max.equal?(a), [a, a].min.equal?(a)
