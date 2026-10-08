# A String forwarded through a rest to the 17th position of a method that
# appends to it: past the 16 positions the forwarding analysis tracks, so it
# cannot be pulled into the shared handle. Refused rather than compiled with
# the append lost (#6179).
# spinel: reject-share
def m(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16) = (a16 << "!"; nil)
def w(*r) = m(*r)
s = +"s"
w(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, s)
p s
