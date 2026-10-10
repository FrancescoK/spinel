# A program's own <=> on a builtin class, called on a receiver whose type is
# known only at run time (a boxed value, or any Integer under
# --int-overflow=promote): the program's method answers for that class, and
# the builtin's for the rest. The boxed compare went to the runtime's
# <=>, which knows only the builtin one.
class Co
  def coerce(n) = [n, 5]
end
class Integer
  def <=>(o) = 7
end
int_or_float = ARGV.size > 0 ? 1.5 : 4
float_or_int = ARGV.size > 0 ? 4 : 2.5
int_or_nil = ARGV.size > 0 ? nil : 3
nil_or_int = ARGV.size > 0 ? 3 : nil
p int_or_float <=> Co.new
p float_or_int <=> Co.new
p float_or_int <=> 3.0
p int_or_nil&.<=>(Co.new)
p nil_or_int&.<=>(Co.new)
p [int_or_float, float_or_int].map { |x| x <=> Co.new }
