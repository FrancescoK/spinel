# spinel: share
# A chain of String appends longer than the 64 links one emission flattens
# (`s << a << b << ...`) is compiled to C under --share-strings without the
# time doubling with each link. Past that length the receiver of the outermost
# links is a call whose representation repr_of is asked, and each link
# asked it of the one below twice (strh_handle_call through
# comp_recv_type, and repr_boxed_native_handle), so the compile grew twice
# as slow per link: more than a minute at 65 links. This chain is a hundred
# links; make scale-test compiles it under a CPU-time limit. Both names
# see every change, so the upcase! reaches the Hash's value.
s = +"a"
s << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x" << "x"
t = s
h = {k: t}
s.upcase!
p h, t.size, s.equal?(t)
u = +"b"
v = (u << "y" << "y" << "y").concat("z")
w = {k: v}
u.upcase!
p w, v.size
