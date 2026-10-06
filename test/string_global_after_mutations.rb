# A global written from a String local after every in-place change the
# program makes: nothing changes either name later, so the copy the global
# holds answers as CRuby's one String does, and the global route of the
# String refusals leaves it alone (master's string_handle_static_slot_reads
# shapes). A change after the write is still refused
# (test/reject/string_global_alias_mutation.rb).
def f(v) = v.size
s = +"a"
s << "b"
$g = (t = s)
p f($g)
$h = s
p $h, t
