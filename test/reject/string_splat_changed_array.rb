# A local Array the program changes after its literal, splatted into a
# parameter that appends: a String the container rule cannot make the
# shared handle -- a global pushed into it -- reaches the parameter as a
# copy, so the append would not reach the global's String. Refused rather
# than compiled with the append lost (#6179).
# spinel: reject-share
f = ->(x, y) { y << "!" }
$g = +"g"
s = [+"a"]
s << $g
f.call(*s)
p $g
