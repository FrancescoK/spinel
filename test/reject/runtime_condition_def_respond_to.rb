# spinel: reject-subclass: a method defined under a condition only the run time decides is not answered for
# The method exists only if the branch ran, but its name answers from the
# start here: respond_to? naming it is refused rather than answered true.
class Shape
  if ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def area = 1
  end
end
p Shape.new.respond_to?(:area)
