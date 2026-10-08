# The String a global Array holds is appended to through each's block
# parameter. A global's Array holds plain Strings, never the shared handle,
# so the append would not reach the element: refused, not compiled with
# ["y"].
# spinel: reject-share
$b = []
$b.push(+"y")
$b.each { |y| y << "?" }
p $b
