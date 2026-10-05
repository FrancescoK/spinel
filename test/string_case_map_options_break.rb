# A case-mapping call given options and a block that breaks: CRuby ignores
# the block, so the break never runs, and checks the options as it does
# without one. The break wrapper hoisted the call ahead of the temp the
# option check held a computed receiver in, and the C did not build.
def t
  yield
rescue ArgumentError => e
  p [e.class, e.message]
end

def run(k)
  log = []
  s = +"ab"
  a = :ascii
  x = (log << 1; s).upcase((log << 2; a)) { break 0 if log.size > 9 }
  p [x, log]
  y = (log << 3; s).swapcase((log << 4; :turkic)) { break 0 }
  p [y, log]
  z = (log << 5; :sym).capitalize((log << 6; a)) { break 0 }
  p [z, log]
  w = (log << 7; s).downcase!((log << 8; :fold)) { break 0 }
  p [w, s, log]
  v = s.upcase!(a) { break 0 if k > 9 }
  p [v, s]
  t { (log << 9; s).capitalize!((log << 10; :bogus)) { break 0 } }
  t { p (log << 11; :sym).swapcase((log << 12; :fold)) { break 0 } }
  p [s, log]
end

run(ARGV.size)
