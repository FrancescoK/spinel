# A String a global variable holds, passed to an `initialize` that appends
# to its parameter: `new` shares a local's String with the method, but a
# global cannot be pulled into the shared handle yet, so the call would
# hand the method a copy and the append would not reach `$s` (CRuby prints
# "a!"). Refused at compile time until it can be shared (#6179).
# spinel: reject-share
class Box
  def initialize(s) = (s << "!")
end
$s = +"a"
Box.new($s)
p $s
