# A case with no subject tests each when condition for Ruby truthiness, as
# `if` does, so a class or 0 is true, where a class failed the C build and
# 0 took the next arm.
x = 5
r = case
    when Object then :obj
    else :no
    end
p r
case
when Integer then p :int
when x > 3 then p :big
end
z = 0
p(case; when z then :zero; else :no; end)
n = nil
p(case; when n then :nil; when x > 3 then :big; end)
# an empty literal and a splat keep their earlier reading
p(case; when [] then :empty; else :no; end)
l2 = [nil, 0]
p(case; when *l2 then :hit; else :miss; end)
