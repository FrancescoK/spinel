# A NaN lies in no Float Range: Float#<=> answers nil against either bound,
# so CRuby's cover?, include?, member? and === answer false, for an
# exclusive, endless or beginless Range too, and `when 0.0..5.0` does not
# match it. sp_frange_cover tested `x < first` and `x > last`, both false
# for a NaN, and let it through. The probes reach it through typed and
# boxed Ranges, a boxed NaN, case/when, grep and a mixed-bound Range.

nan = Float::NAN
r = (0.0..5.0)
p r === nan, r.cover?(nan), r.include?(nan), r.member?(nan)
e = (0.0...5.0)
p e === nan, e.cover?(nan), e.include?(nan), e.member?(nan)
p((0.0..) === nan, (0.0..).cover?(nan), (..5.0) === nan, (..5.0).cover?(nan), (...5.0).include?(nan))
p((-Float::INFINITY..Float::INFINITY) === nan)
p((0..5.0) === nan, (0.0..5) === nan)
p((0..5) === nan, (0..5).cover?(nan))
case nan
when 0.0..5.0 then p :in
else p :out
end
a = [r, 1, "s"]
p a[0] === nan, a[0].cover?(nan), a[0].include?(nan)
x = [nan, 1][0]
p r === x, r.cover?(x), r.member?(x)
p [0.0, 5.0, nan].grep(r)
p [0.0, 5.0, nan].select { |v| e === v }

# and everything else is unchanged
p r.cover?(2.0), r === 5.0, e === 5.0, r.include?(0.0), (..5.0) === -1e300
