# A String a block parameter holds, passed by keyword to a proc that
# appends to its keyword: a proc shares a local's String passed by keyword
# as it does one passed by position, but a block parameter cannot be pulled
# into the shared handle yet, so the call would hand the proc a copy and
# the append would not reach the Array's element (CRuby prints ["a!"]).
# Refused at compile time until it can be shared (#6179).
# spinel: reject-share
f = proc { |k:| k << "!" }
a = [+"a"]
a.each { |s| f.call(k: s) }
p a
