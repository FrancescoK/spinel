# A Struct built through a receiver chosen by a `case`/`when`, one arm of which is a
# class value no analysis names (`Object.const_get(name)`): the run-time
# switch has to build any Struct of the program, with the arguments given. The
# classes the arms name were taken as all there were, so only P was built and
# the Q the call answers at run time was read as a P: the program faulted.
P = Struct.new(:a)
Q = Struct.new(:a)
q = Q.new("str")
puts q.a
name = ARGV.size == 0 ? :Q : :P
r = (case ARGV.size when 9 then P else Object.const_get(name) end).new(7)
p r.a
p r.class
