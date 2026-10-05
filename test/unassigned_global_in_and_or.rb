# A global the program never assigns reads nil (or, for the interpreter's
# own $DEBUG and $VERBOSE, false). Beside a Boolean in && / || the
# expression answers whichever operand decides it (webrick's
# `if backtrace && $DEBUG`).
def show(backtrace) = (backtrace && $DEBUG) ? "bt" : "plain"
def either(b) = b || $nothing_set
p show(true), show(false)
p either(false), either(true)
p(true && $nothing_set)
p(false || $VERBOSE)
