# `$VERBOSE` and `$DEBUG` are the interpreter's flags: a ruby run without
# -w or -d reads both as false, where they read nil before any write. A nil
# `$VERBOSE` silences Kernel#warn, an uplevel: prefix included (its messages
# still evaluate), and `$-v`, `$-w` and `$-d` are other names for the same
# flags. stderr is checked by the .err.expected file.
p $VERBOSE, $DEBUG, $VERBOSE.nil?, $-v, $-w, $-d

def quiet
  old = $VERBOSE
  $VERBOSE = nil
  yield
ensure
  $VERBOSE = old
end

n = 0
quiet do
  warn "hidden #{n += 1}"
  warn "hidden too", category: :deprecated
  warn "hidden with its prefix", uplevel: 0
  p $VERBOSE, $-w
end
p n, $VERBOSE
warn "shown 1"
$-w = nil
p warn("hidden 2")
$-v = true
p $VERBOSE, $-w
warn "shown 2"
$VERBOSE = false
p [$VERBOSE, $-v, $DEBUG ? 1 : 2]
