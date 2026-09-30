# promote-only: the operators of yield_operator_diverging_block_types.rb under
# --int-overflow=promote. Integer `+ - *` take the boxed promotion path there
# and may answer a Bignum; Integer `/` and `%` still answer a raw Integer, and
# each has to reach the method's boxed value as the site's own type.

def twice = yield + yield
p twice { "a" }
p twice { 1.5 }
p twice { 1 << 62 }

def diff = yield - yield
p diff { 5 }
p diff { 1.5 }

def squared = yield * yield
p squared { 1 << 40 }
p squared { 1.5 }

def halves = yield / 2
p halves { 7 }
p halves { 7.0 }

def rem = yield % 3
p rem { 7 }
p rem { 7.5 }
p rem { "value=%d" }
