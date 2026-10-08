# A boxed parameter (x takes nil at one call) yielded under a second name
# to a block that appends: a local is pulled into the shared handle, but a
# global goes into the box as a copy, so the call is refused.
# spinel: reject-share
def w(x); z = x; yield z; x; end
w(nil) { |q| q }
$g = +"g"
w($g) { |q| q << "!" }
p $g
