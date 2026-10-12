# A `when` arm whose class defines === is asked with the subject, whatever
# its kind: a String subject answered false without asking.
class Big
  def ===(x) = x.to_s.size > 1
end
B = Big.new
p B === 12
p(case "abc" when B then :long else :short end)
p(case "a" when B then :long else :short end)
p(case :ab when B then 1 else 2 end, case 1.5 when B then 1 else 2 end, case nil when B then 1 else 2 end)
p(case [1, 2] when B then 1 else 2 end, case({a: 1}) when B then 1 else 2 end)
r = case "zz" when 1, B then :hit else :miss end
p r
case "q"
when B then puts "long"
when "q" then puts "q"
end

# a truthy answer that is no boolean
class Truthy
  def ===(x) = (x.size > 2 ? x : nil)
end
T = Truthy.new
p(case "abc" when T then :t else :f end, case "ab" when T then :t else :f end)

# an object's own === on a constant, before and after its def
M = Object.new
p(case "hi" when M then 1 else 2 end)
def M.===(x) = x.start_with?("h")
p(case "hi" when M then 1 else 2 end, case "ho" when M then 1 else 2 end)
v = case "hello" when M then :h else :other end
p v

# an == of its own answers Object#=== too
class Eq
  def ==(o) = o.to_s == "eq"
end
E = Eq.new
p(case "eq" when E then :yes else :no end, case "x" when E then :yes else :no end)
