def absolute = yield.abs
p absolute { -3 }
p absolute { -2.5 }

def negate = yield.-@
p negate { 5 }
p negate { 3.14 }
