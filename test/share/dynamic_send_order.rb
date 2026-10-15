# A computed-name send evaluates its receiver, then its name, then its
# arguments, wherever the send sits, and runs none of them when the
# enclosing code does not reach it: in an interpolation, a multiple
# assignment, a hash literal, a `when` clause, an array literal.
$log = []
$s = +"abc"
def get = ($log << :recv; $s)
def tick(x) = ($log << x; x)
names = [:to_s, :size]

r = "#{tick(1)}-#{get.send(names[0])}-#{tick(2)}"
p r, $log
$log.clear
r = "#{tick(1)}#{get.send((tick(:n); names[0]))}#{tick(2)}"
p r, $log
$log.clear
a, b = tick(1), get.send(names[0])
p a, b, $s, $log
$log.clear
h = { tick(:k) => get.send(names[0]) }
p h, $log
$log.clear
arr = [tick(0), "#{tick(1)}#{get.send(names[0])}"]
p arr, $log

$cnt = 0
def getc = ($cnt += 1; $s)
x = "zzz"
r = case x
    when "zzz" then :early
    when getc.send(names[0]) then :late
    end
p r, $cnt
x = "abc"
r = case x
    when "q" then :q
    when getc.send(names[0]) then :late
    end
p r, $cnt
