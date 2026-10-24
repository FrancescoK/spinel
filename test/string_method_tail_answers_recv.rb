# A method whose answer is a builtin String call that answers its receiver
# (`s.tap { }`) answers the String itself: its return cleared the channel
# the caller finds the handle by, as for a call making a new String, so
# `tr(s).equal?(s)` was false.
def tr(s) = s.tap { |x| x = +"other" }
def im(s) = s.itself
def th(s) = s.then { |x| x }
def ins(s) = s.insert(0, "<")
def dp(s) = s.dup
s = +"q"
p tr(s).equal?(s)
p im(s).equal?(s)
p th(s).equal?(s)
p ins(s).equal?(s)
p dp(s).equal?(s)
