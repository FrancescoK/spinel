# The string old generation's MAJOR has two policies, and this is the shape
# that tells them apart (#4407).
#
# The true live string set here is far above the pinned string floor, so a
# string is promoted the first sweep it survives and most of what is promoted
# is garbage that happened not to have died yet. The default gate then re-aims
# itself to twice what the last major left -- a number that same early
# promotion inflated -- so it ratchets away from the live set and the old
# generation grows without bound in a program whose live set never does.
#
# SPINEL_GC_STR_MAJOR=interval runs the major on a schedule instead, the way
# sp_gc_collect has always run the object full collection, and demotes the size
# test to a backstop for growth between scheduled majors. On this shape that
# fires the major more often and leaves less old behind, which is what the
# gc-str-major-test leg asserts -- as a comparison of the two arms on the same
# machine, never as an absolute either one has to hit.
#
# The answer must be identical under both, which is the other half of the leg:
# a collection policy that changes what a program prints is not a policy.
#
# Each fragment's Integers go through an explicit to_s, so every part leaves
# a short String behind as garbage: that churn is part of the shape. An
# interpolation appended into a String writes its Integer digits in place and
# leaves none, which moved where the two arms' last majors fall and made the
# leg read one arm's end-of-run snapshot just before its major and the other's
# just after.
KEEP = (ENV["K"] || "3000").to_i
ROUNDS = (ENV["R"] || "40000").to_i
PARTS = (ENV["P"] || "80").to_i
CACHE = []

def page(i)
  b = String.new
  j = 0
  while j < PARTS
    b << "frag-" << i.to_s << "-" << j.to_s << "-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    j += 1
  end
  b
end

r = 0
while r < ROUNDS
  CACHE << page(r)
  CACHE.shift while CACHE.size > KEEP
  r += 1
end
puts "kept #{CACHE.size} len #{CACHE[0].to_s.size} last #{CACHE[-1].to_s[0, 20]}"
