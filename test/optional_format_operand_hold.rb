# format_made_in_place_held shape with $n still nil when held
def counted = ($n += 1 if $n; "%p|")
p counted % $n
$n = 0
p counted % $n
