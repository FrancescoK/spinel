# A bang that answers nil when it changes nothing, over an append chain on
# a shared String (`($t << x).upcase!`), as an Array or Hash element: the
# chain's bytes are the handle's own buffer, which the bang's write-back
# rewrites, so whether it changed is decided before the write. Each bang
# runs once on contents it changes and once on contents it leaves alone,
# one container to a `p`; $keep holds each String the global names. Kept
# in a variable, the element is the global's String itself.
$t = +"ab"
$keep = [$t]
p [($t << "z").upcase!, $t]
p [($t << "").upcase!, $t]
p [($t << "Q").downcase!, $t]
p [($t << "").downcase!, $t]
p [($t << "").capitalize!, $t]
p [($t << "").capitalize!, $t]
p [($t << "B").swapcase!, $t]
p [($t << "").swapcase!, $t]
p [($t << "bb").squeeze!, $t]
p [($t << "").squeeze!, $t]
p [($t << "\n").chomp!, $t]
p [($t << "").chomp!, $t]
p [($t << "z").chop!, $t]
p [($t << " ").rstrip!, $t]
p [($t << "").rstrip!, $t]
$t = +" ab"
$keep << $t
p [($t << " ").strip!, $t]
p [($t << "").strip!, $t]
p [($t << "x").lstrip!, $t]
p({a: ($t << "a").sub!("a", "A"), b: $t})
p({a: ($t << "").sub!("q", "Q"), b: $t})
p({a: ($t << "a").gsub!("A", "a"), b: $t})
p({a: ($t << "").gsub!("q", "Q"), b: $t})
p [($t << "c").tr!("c", "C"), $t]
p [($t << "").tr!("q", "Q"), $t]
p [($t << "d").delete!("d"), $t]
p [($t << "").delete!("q"), $t]
p [($t << "").reverse!, $t]
p [($t << "").delete_prefix!("b"), $t]
p [($t << "").delete_suffix!("q"), $t]
p $keep
y = [($t << "z").upcase!, $t]
p y, y[0].equal?($t)
z = {a: ($t << "Y").downcase!, b: $t}
p z, z[:a].equal?($t)
