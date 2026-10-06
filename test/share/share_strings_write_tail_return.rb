# Flag-only: without the flag each call below answers a copy.
# A method whose tail is a write into a slot that holds the shared handle
# (an ivar's `=` or `||=`, a global's), endless or a statement, last in a
# sequence or a begin, answers that slot's String: the caller takes the
# handle the tail publishes, as for a tail that reads the slot, so a change
# through either name shows through the other.
def g = (@k = +"k")
t = g; @k << "!"; p t
def j = (@m ||= +"m")
u = j; u << "!"; p @m
def h = ($q = +"q")
v = h; $q << "!"; p v
# the statement form, a sequence, a begin with an ensure or a rescue, a
# global's statement form
def gs; @ks = +"k"; end
t2 = gs; @ks << "!"; p t2
def gq = (1; @kq = +"k")
t3 = gq; @kq << "!"; p t3
def ge; begin; @ke = +"k"; ensure; @z = 1; end; end
t4 = ge; @ke << "!"; p t4
def gr; begin; @kr = +"k"; rescue; @kr = +"r"; end; end
t5 = gr; @kr << "!"; p t5
def hs; $qs = +"q"; end
t6 = hs; $qs << "!"; p t6
