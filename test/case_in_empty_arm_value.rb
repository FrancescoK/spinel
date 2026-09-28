# A case/in whose matching arm is empty, or ends in nil or in a call that
# answers nothing, answers nil as a value, as CRuby does, where the C build
# failed.
r = case 5
    in Integer
    end
p r
v = case [1]
    in [Integer] then
    end
p v
def f(x) = case x
           in String
           end
p f("s")
w = case 3
    in 3 then :three
    in Integer
    end
p w
n = case 5
    in Integer then nil
    end
p n
m = case 5
    in Integer then puts "side"
    end
p m
