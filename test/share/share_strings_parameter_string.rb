# A String among the callers still counts as mutation; both aliases see it.
def keep_string(keep = nil)
  keep << "!" if keep
end
s = +"s"
t = s
keep_string(s)
keep_string([])
keep_string(nil)
p [s, t, s.equal?(t)]

