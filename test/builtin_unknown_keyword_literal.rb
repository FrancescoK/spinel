# A literal keyword a builtin does not take raises CRuby's ArgumentError,
# once the keyword values have run in order, as a `**` operand holding the
# same key already did. The call read the keyword it knows and answered as if
# the others were not there: `s.unpack("C", offset: 0, other: x)` answered
# [1], and `lines(chomp: true, other: x)` dropped x without running it.
# unpack, unpack1, lines and clone take one keyword on every receiver;
# IO's gets, each_line and readlines accept others, so those stay as they are.

$ran = []

def note(v)
  $ran << v
  v
end

def try(label)
  $ran.clear
  p yield
rescue ArgumentError => e
  puts "#{label}: ArgumentError: #{e.message} (ran #{$ran.inspect})"
end

# a datagram naming Jayang Station on Line 7, as a reader hands it over
msg = [7, 0x4a59].pack("Cn") + "Jayang Station".b
q = Queue.new
q << msg
boxed = q.pop

try("unpack, typed") { msg.unpack("C", offset: note(0), exit: note(2)) }
try("unpack, boxed") { boxed.unpack("C", offset: note(0), exit: note(2)) }
try("unpack1, typed") { msg.unpack1("n", offset: note(1), platform: note(1)) }
try("unpack1, boxed") { boxed.unpack1("n", offset: note(1), platform: note(1)) }
try("unpack, no offset") { msg.unpack("C", line: note(7)) }
try("two unknown") { msg.unpack("C", line: note(2), exit: note(4)) }
# a hash of more than sixteen entries: Line 7 from Jayang to Nowon
try("seventeen entries") do
  msg.unpack("C", offset: note(0), jayang: note(1), konkuk: note(2), grand_park: 3, gunja: 4,
             junggok: 5, yongmasan: 6, sagajeong: 7, myeonmok: 8, sangbong: 9, junghwa: 10,
             meokgol: 11, taereung: 12, gongneung: 13, hagye: 14, junggye: 15, nowon: 16)
end
try("lines") { "Achasan\nHan River\n".lines(chomp: note(true), trail: note(:dawn)) }
try("clone") { "Children's Grand Park".clone(freeze: note(false), gate: note(:main)) }
r, w = IO.pipe
w.write("Kondae\nGuui\n")
w.close
# IO's gets accepts a keyword it does not take, and that stays so
try("gets") { r.gets(chomp: note(true), stop: note(:exit1)) }

# the keyword each method takes still works, alone or through a `**` operand
p msg.unpack("a14", offset: 3)
p boxed.unpack1("C", offset: 0)
p "Achasan\nHan River\n".lines(chomp: true)
p r.gets(chomp: true)
opts = { offset: 1 }
p msg.unpack1("n", **opts)
try("** with an unknown key") { msg.unpack("C", **{ offset: 0, exit: 2 }) }

# an unreached call raises nothing
reached = false
p(reached && msg.unpack("C", offset: 0, exit: note(9)))
