# write_nonblock on a receiver known only at run time, with `exception:`
# read at run time: the operand's String is built once the receiver has
# been unboxed. A receiver that nothing else holds, such as a method's
# answer, has to stay reachable while that String is built; a collection
# there closed its file under the write, "closed stream (IOError)".

def sink(kind) = kind == :io ? File.open("/dev/null", "w") : "Seongsu"

banks = "Han River " * 10_000
[false, true].each do |flag|
  total = 0
  50.times do |i|
    total += sink(:io).write_nonblock("#{banks}#{i}", exception: flag)
    total += sink(:io).write_nonblock(1_000 + i, exception: flag)
  end
  p [flag, total]
end

def pier(kind)
  return "Achasan" unless kind == :io
  File.open("/dev/null", "w")
end

ferries = 0
40.times do |i|
  odd = i.odd?
  ferries += pier(:io).write_nonblock("#{banks}Jayang #{i}", exception: odd)
end
p ferries
p sink(:name)
