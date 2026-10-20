# A container literal held in parentheses that run statements first,
# `x = (log << 1; [[1], [2]])`, is the literal the variable, the instance
# variable, the global or the constant holds. The widening of the literals a
# store reaches (`x[0] << "q"` puts a String into an Array of Integers)
# followed a literal through single-statement parentheses only, so the
# literal under `(stmt; [[1], [2]])` kept its Integer element type and the
# store raised "cannot store String into an Array[Integer]".
$log = []
def lg(x) = ($log << x; x)

x = (lg(:lv); [[1], [2]])
x[0] << "q"
x << :sym
p x

@iv = (lg(:iv); [[3], [4]])
@iv[1] << "r"
p @iv

$gv = (lg(:gv); [[5], [6]])
$gv[0] << "s"
$gv << 1.5
p $gv

CONST = (lg(:co); [[7], [8]])
CONST[1] << "t"
p CONST

y = (lg(:one); (lg(:two); [[9]]))
y[0] << "u"
p y
p $log
