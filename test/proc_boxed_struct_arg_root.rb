# The box of a Range handed to a Proc is held while the Proc runs.
# A Range, a Time or a Rational is a C struct, boxed for the call alone
# when the Proc may take anything. The Proc clears the channel the box came
# through and keeps it in a parameter that nothing roots, so a body that
# allocates before it uses the parameter lost the box. Each round hands a
# value made in place to a Proc through every form of a call and counts the
# answers that are not Ruby's.
# spinel: gc-stress
class Wide
  def call(x) = [x, x].size
end

show = [->(x) { [x, x].to_s }, 1][0]
pair = [->(x, y) { [y, x].to_s }, 1][0]
typed = ->(x) { [x].to_s }
either = [->(x) { [x, x].size }, Wide.new]
bad = 0
300.times do |i|
  got = show.call(i..i + 2)
  bad += 1 unless got == "[#{i}..#{i + 2}, #{i}..#{i + 2}]"
  got = show.(i...i + 1)
  bad += 1 unless got == "[#{i}...#{i + 1}, #{i}...#{i + 1}]"
  got = show.yield(i..i)
  bad += 1 unless got == "[#{i}..#{i}, #{i}..#{i}]"
  got = show[i..i + 5]
  bad += 1 unless got == "[#{i}..#{i + 5}, #{i}..#{i + 5}]"
  got = (show === (i..i + 7))
  bad += 1 unless got == "[#{i}..#{i + 7}, #{i}..#{i + 7}]"
  got = show.call(Rational(i, 7))
  bad += 1 unless got == "[(#{Rational(i, 7)}), (#{Rational(i, 7)})]"
  got = show.call(Complex(i, 2))
  bad += 1 unless got == "[(#{i}+2i), (#{i}+2i)]"
  got = pair.call(i..i + 1, Rational(1, i + 2))
  bad += 1 unless got == "[(1/#{i + 2}), #{i}..#{i + 1}]"
  got = typed.call(i..i + 3)
  bad += 1 unless got == "[#{i}..#{i + 3}]"
  got = either[i & 1].call(i..i + 4)
  bad += 1 unless got == 2
end
got = typed.call("s")
bad += 1 unless got == "[\"s\"]"
p bad

# What the Proc was handed is still whole after it returns.
kept = []
keep = [->(x) { kept << [x.to_s, x] }, 1][0]
4.times { |i| keep.call(i..i * 2) }
p kept
p show.call(Time.at(0).utc).size
