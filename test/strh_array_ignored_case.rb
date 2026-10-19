# An Array of Strings read as the receiver of `each` in the clause of a
# `case` or a `case`/`in` that is a statement of its own has its value
# unused, as one in an `if` arm does, and holds the Strings by handle. The
# climb that finds the value unused stopped at a clause.
k = 1 + ARGV.size
names = [+"a", +"b"]
if k == 1
  names.each { |q| q << "!" }
end
p names

other = [+"c", +"d"]
case k
when 1
  other.each { |q| q << "?" }
end
p other

third = [+"e", +"f"]
case k
in 1
  third.each { |q| q << "#" }
end
p third
