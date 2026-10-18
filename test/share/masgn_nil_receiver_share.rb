# A multiple assignment into an element or an attribute of a receiver
# that is nil raises NoMethodError, as the single assignment does, once the
# right side has run. The Array of String handles a later `w[0] << "!"`
# asks for skipped the store silently (the failure then came from the
# read), and an attribute store on a nil object read the field of NULL.
class Box
  attr_accessor :a, :b
end

def show
  p yield
rescue NoMethodError => e
  puts e.message
end

def side(x)
  puts "rhs #{x}"
  x
end

n = ARGV.size

w = unless n == 0 then [+"p"] end
show { w[0], w[1] = "a#{n}", "b".dup; w[0] << "!"; w }

w = n == 0 ? nil : [+"p"]
show { w[0], w[1] = "a#{n}", "b".dup; w[0] << "!"; w }

w = case n when 3 then [+"p"] end
show { w[0], w[1] = "a#{n}", "b".dup; w[1] << "?"; w }

w = ([+"p"] if n > 5)
show { w[0], w[1] = "a#{n}", "b".dup; w[0] << "!"; w }

w = nil
w = [+"p"] if n > 5
show { w[0], w[1] = "a#{n}", +"b"; w[0] << "!"; w }

w = if n > 5 then [+"p"] elsif n == 0 then nil else [+"q"] end
show { w[0], w[1] = side("c"), side("d"); w[0] << "!"; w }

w = unless n == 0 then [+"p"] end
show { w[0] = "x#{n}"; w[0] << "!"; w }

o = unless n == 0 then Box.new end
show { o.a, o.b = side(3), side(4); o }

o = nil
o = Box.new if n > 5
show { o.a, o.b = "s", +"t"; o.a << "!"; o }

w = unless n == 0 then [+"p"] end
w = [+"ok"] if n == 0
show { w[0], w[1] = "a#{n}", "b".dup; w[0] << "!"; w }
