# `alias $b $a` makes $b the same global as $a, which holds s. The append
# through $b changes s in CRuby; it changed a copy and s stayed "abc":
# refused, not compiled wrong.
alias $b $a
s = +"abc"
$a = s
$b << "!"
p s
