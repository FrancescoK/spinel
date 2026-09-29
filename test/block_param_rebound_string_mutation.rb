# A block parameter the block reassigns and then mutates in place builds:
# the iterator hands it a plain String, so the incoming slot stays one while
# the local it is rebound to takes the mutable handle.
["", "abcd", "THX1138"].each do |s|
  s = +s
  r = s.dup.succ!
  s.succ!
  p [s, r]
end
%w[x y].each do |w|
  w = w + "!"
  w << "?"
  p w
end
