# A block argument that is one of two lambda literals, chosen at run time
# (block_arg_one_of_two_lambdas.rb): no call site types either literal's
# parameter, so both are widened to a boxed value. The walk that finds the
# literals stopped at a `case`/`in`, found one literal and widened none, and the
# string concatenation in the lambda raised TypeError ("String can't be
# coerced into Integer").
def m(f)
  pr = case f
  in true then lambda { |s| s + "!" }
  else lambda { |s| s + "?" }
  end
  p ["a", "b"].map(&pr)
  p "ab".each_char.map(&pr)
end

m(true)
m(false)
