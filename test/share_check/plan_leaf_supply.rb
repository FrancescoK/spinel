# The String plan's supply of a value taken arm by arm (#8328): a plain
# String local among the arms of a begin, a conditional or a loop's break
# is held as its bytes, so the value's identity is the bytes', not a
# handle.
pd = +"d"
p pd.equal?(begin; pd; end), pd.equal?(loop { break pd })
pe = "e#{ARGV.size}"
p pe.equal?(ARGV.size == 0 ? pe : nil), (begin; raise "x"; rescue; pe; end).equal?(pe)
ph = +"h"
ph << "!"
p ph.equal?(begin; ph; end), ph.equal?(loop { break ph }), ph
