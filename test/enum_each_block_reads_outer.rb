# `e.each { }` over an Enumerator, in a method, with a block that reads the
# method's own variables: the walk runs the block in place. The block was
# written as a proc too, for the walk a bsearch Enumerator takes, and with
# no capture for those variables the call was refused at compile time.

def pairs(xs) = xs.sort.each_slice(2)

def report(node, xs)
  pairs(xs).each do |(a, b)|
    next if a == node
    p [node, a, b]
  end
end
report(1, [4, 1, 3, 2, 6, 5])

def tagged(tag, e)
  seen = 0
  e.each { |w| seen += 1; p [tag, w] }
  seen
end
p tagged(:s, [1, 2, 3].each_slice(2))
p tagged(:c, [1, 2, 3].each_cons(2))
p tagged(:e, [4, 5].each)
