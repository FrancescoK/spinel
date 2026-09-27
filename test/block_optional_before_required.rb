# A block's optional parameter before a required one takes its default
# when the yield carries only enough values for the requireds.

def one = yield(5)
one { |a = {}, c| p [a, c] }
one { |a = "s", c| p [a, c] }
one { |a = [], c| p [a, c] }
one { |a = 1, b = 2, c| p [a, b, c] }

def two = yield(5, 6)
two { |a = {}, c| p [a, c] }
two { |a = 1, b = 2, c| p [a, b, c] }

def pair = yield([5, 6])
pair { |a = {}, c| p [a, c] }

def mixed
  yield 5
  yield "s", 6
end
mixed { |a = 1, c| p [a, c] }

one { |c, a = {}| p [a, c] }
two { |c, a = {}| p [a, c] }
