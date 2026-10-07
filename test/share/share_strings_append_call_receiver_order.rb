# Flag-only: without --share-strings a String a method answers as its parameter is refused when it is mutated in place.
# The receiver of a String append is a call answering the String (a method
# returning its parameter, or a global); Ruby runs it once, before the
# arguments. The statement form passed the call to C beside the argument, so
# gcc ran the argument first, and a second link, an Integer's codepoint
# conversion or a multi-argument concat ran the receiver again. A receiver
# call assigning the global its argument reads ran after that read.
def recv(s) = (puts "recv"; s)
def arg(x) = (puts "arg #{x}"; x)
def num(n) = (puts "num #{n}"; n)

s = +"s"
recv(s) << arg("a")
recv(s).concat(arg("b"))
recv(s).concat(arg("c"), arg("d"))
recv(s) << arg("e") << arg("f")
recv(s) << num(33)
recv(s) << "#{arg("g")}h"
p s

$g = +"g"
def grecv = (puts "grecv"; $g)
grecv << arg("x")
grecv.concat(arg("y"), arg("z"))
p $g

def recv_x(s) = ($x = +"new"; s)
$x = +"old"
t = +"t"
recv_x(t) << $x
p t
