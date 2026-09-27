def blk(code, track = 0) = yield("#{code},#{track}")
def fb(*, &) = blk(*, &)
fb(26, 18) { |s| puts s }
fb("b") { |s| puts s }
blk(*[26, 18]) { |s| puts s }
