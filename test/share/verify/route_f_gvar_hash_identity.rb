$g = +"g"
h = {g: $g}
$g << "!"
p h[:g], h[:g].equal?($g)
