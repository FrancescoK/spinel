# An Array of Strings read as the receiver of `each` in parentheses that are
# the body of an `if` has its value unused, as one outside them does, and
# holds the Strings by handle. The climb that finds the value unused stopped
# at the parentheses.
k = 1 + ARGV.size
names = [+"a", +"b"]
if k == 1
  (names.each { |q| q << "!" })
end
p names
