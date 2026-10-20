def pa = (1..40).map { |i| i.odd? ? i * 10 : "s#{i}" }
def r; print("R"); pa; end
p r.dig(*(print("K"); [5]))

# The receiver is captured before a splat mutates the receiver local.
a = [[10, "old"], [20, "later"]]
p a.dig(*(a = [[30, "new"]]; GC.start; [0, 1]))
p a
# A typed Hash uses the same single-splat helper.
def hash_receiver
  print "H"
  {key: [7, "value"]}
end
p hash_receiver.dig(*(print "K"; GC.start; [:key, 1]))
