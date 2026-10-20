# Complex#=== is #==, so a Complex compares by value in === and in
# case/when, with a Complex on either side
c = Complex(1, 2)
p(c === Complex(1, 2))
p(c === 1)
p(Complex(1, 0) === 1)
p(Complex(1, 0) === 1.0)
p(Complex(2, 0) === Rational(2))
p(c === nil)
p(c === "c")
a = [c, 1]
p(a[0] === Complex(1, 2))
p(Complex(1, 2) === a[0])
p [Complex(1, 2), 3, Complex(1, 2)].grep(Complex(1, 2))
# a value that is no number is unequal, through an Array element too
m = [Complex(1, 0), "x", nil, :s, 1]
p m.grep(Complex(1, 0))
p(Complex(0, 0) === m[1])
p(Complex(0, 0) === m[2])

case c
when Complex(1, 2) then p :hit
else p :miss
end
case c
when 1, 2 then p :int
when Complex(1, 2) then p :second
end
case Complex(3, 0)
when 3 then p :integer_label
end
case 3.0
when Complex(3, 0) then p :float_subject
end
case Complex(3, 1)
when 3 then p :wrong
else p :no_match
end
r = case Complex(0, 1)
    when Complex(0, 1) then :value
    end
p r
