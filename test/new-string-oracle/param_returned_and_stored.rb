# A method that answers its parameter answers a new String for a new
# argument only while nothing else holds the parameter. This one also
# stores it in $g, so its answer is the String $g keeps. The compiler once
# counted w, and the call in it, as new; param_returned_and_stored.claims is
# what it claimed then, and the oracle must disprove it.
$g = nil
def gkeep(x)
  $g = x
  x
end

def w = gkeep(+"n")

r = w
r << "!"
p r, $g, r.equal?($g)
