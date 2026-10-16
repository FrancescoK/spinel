# The oracle's self-test (tools/new_string_oracle_test.rb): one program, and
# a hand-written .claims file with true claims and false ones, one of each
# check the file can ask for. The compiler is not involved, so the test needs
# no compiler bug to exist.
$held = nil
$a = +"two names"
$b = $a
$c = +"one name"
def fresh = +"new"
def held = ($held ||= +"kept")
def same(x) = x
def other(x) = $held
fresh_one = fresh
held_one = held
p fresh_one, held_one, same(+"p"), other(+"q")
two = $a
one = $c
p two, one
s = +"dup"
p [+"a", +"b"], [s, s]
mystery = held
p mystery
