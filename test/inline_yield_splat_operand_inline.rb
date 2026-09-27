def pairs(n) = yield([n, n + 1])

def blk(code, track = 0)
  tmp = code * 2
  yield("#{tmp},#{track}")
end

blk(*pairs(3) { |a| a }) { |s| puts s }
blk(1, *pairs(5) { |a| a.take(1) }) { |s| puts s }
