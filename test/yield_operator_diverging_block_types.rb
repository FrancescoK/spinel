# A builtin arithmetic operator on a yield, from a method whose blocks answer
# different types at different call sites. The operator was typed from the
# first site's block, so `yield + yield` with a String block and then a Float
# one put the Float into a `const char *` and the C did not compile. Codegen
# already lowers the operator per site; its result is now boxed into the
# method's value.

def twice = yield + yield
p twice { "a" }
p twice { 1.5 }
p twice { 7 }

def doubled = yield * 2
p doubled { "ab" }
p doubled { 2.5 }
p doubled { 4 }

def diff = yield - yield
p diff { 5 }
p diff { 1.5 }

def halves = yield / 2
p halves { 7 }
p halves { 7.0 }

def rem = yield % 3
p rem { 7 }
p rem { 7.5 }
p rem { "value=%d" }

def plus_one = yield + 1
p plus_one { 7 }
p plus_one { 1.5 }

def product = yield(2) * yield(3)
p product { |x| x }
p product { |x| x.to_f }

def squared = yield * yield
p squared { 3 }
p squared { 1.5 }

# inside another block, and beside a plain yield in an array
def mapped = [1].map { yield + yield }.first
p mapped { "c" }
p mapped { 0.5 }

def pair = [yield + yield, yield]
p pair { "a" }
p pair { 2 }
