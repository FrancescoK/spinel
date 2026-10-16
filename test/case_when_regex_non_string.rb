# `when /re/` against a number, true, false or nil is false, as Regexp#===
# answers for anything that is no String or Symbol. The literal's pattern was
# compared with the Integer as a pointer, which the C compiler warns about.
DIGITS = /\A\d+\z/

def kind(x)
  case x
  when /\A\d+\z/ then :digits
  when 5 then :five
  else :other
  end
end

def kind_f(x)
  case x
  when DIGITS then :digits
  when 1.5 then :one_half
  else :other
  end
end

def kind_b(x)
  case x
  when /true/ then :matched
  when true then :true
  else :false
  end
end

p kind(5), kind(6)
p kind_f(1.5), kind_f(2.5)
p kind_b(true), kind_b(false)
p(case nil when /x/ then :x else :none end)
