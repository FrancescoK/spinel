# spinel: gc-minor
# An attribute assignment's value, taken by `freeze` (the same String, frozen),
# by a chain of mutators, by a call that only reads it, and through a safe
# navigation whose receiver is nil. Each class has variables of its own: a
# receiver of several classes stays refused.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
class Wr
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
S = Struct.new(:a)

oacc = Acc.new
sacc = +"s"
xacc = (oacc.a = sacc).freeze
p [xacc.equal?(sacc), xacc.frozen?, oacc.a.frozen?, sacc.frozen?]
oacc2 = Acc.new
sacc2 = +"s"
(oacc2.a = sacc2) << "!" << "?"
p [oacc2.a, sacc2]
oacc3 = Acc.new
sacc3 = +"s"
(oacc3.a = sacc3).concat("1").concat("2")
p [oacc3.a, sacc3]
oacc4 = Acc.new
sacc4 = +"s"
((oacc4.a = sacc4) << "!").upcase!
p [oacc4.a, sacc4]
oacc5 = Acc.new
sacc5 = +"s"
tacc5 = "#{(oacc5.a = sacc5) << "!" << "?"}"
p [oacc5.a, sacc5, tacc5]
oacc6 = Acc.new
sacc6 = +"sab"
uacc6 = [(oacc6.a = sacc6).upcase, (oacc6.a = sacc6).size, (oacc6.a = sacc6).bytes, (oacc6.a = sacc6).chars, (oacc6.a = sacc6).start_with?("s")]
sacc6 << "1"
p [oacc6.a, sacc6, uacc6]
nacc7 = ARGV.size == 0 ? nil : Acc.new
sacc7 = +"s"
racc7 = (nacc7&.a = sacc7)&.<<("!")
p [racc7, sacc7]
macc8 = Acc.new
sacc8 = +"s"
racc8 = (macc8&.a = sacc8)&.<<("!")
p [macc8.a, sacc8, racc8]
ost = S.new(+"x")
sst = +"s"
xst = (ost.a = sst).freeze
p [xst.equal?(sst), xst.frozen?, ost.a.frozen?, sst.frozen?]
ost2 = S.new(+"x")
sst2 = +"s"
(ost2.a = sst2) << "!" << "?"
p [ost2.a, sst2]
ost3 = S.new(+"x")
sst3 = +"s"
(ost3.a = sst3).concat("1").concat("2")
p [ost3.a, sst3]
ost4 = S.new(+"x")
sst4 = +"s"
((ost4.a = sst4) << "!").upcase!
p [ost4.a, sst4]
ost5 = S.new(+"x")
sst5 = +"s"
tst5 = "#{(ost5.a = sst5) << "!" << "?"}"
p [ost5.a, sst5, tst5]
ost6 = S.new(+"x")
sst6 = +"sab"
ust6 = [(ost6.a = sst6).upcase, (ost6.a = sst6).size, (ost6.a = sst6).bytes, (ost6.a = sst6).chars, (ost6.a = sst6).start_with?("s")]
sst6 << "1"
p [ost6.a, sst6, ust6]
nst7 = ARGV.size == 0 ? nil : S.new(+"x")
sst7 = +"s"
rst7 = (nst7&.a = sst7)&.<<("!")
p [rst7, sst7]
mst8 = S.new(+"x")
sst8 = +"s"
rst8 = (mst8&.a = sst8)&.<<("!")
p [mst8.a, sst8, rst8]
owr = Wr.new
swr = +"s"
xwr = (owr.a = swr).freeze
p [xwr.equal?(swr), xwr.frozen?, owr.a.frozen?, swr.frozen?]
owr2 = Wr.new
swr2 = +"s"
(owr2.a = swr2) << "!" << "?"
p [owr2.a, swr2]
owr3 = Wr.new
swr3 = +"s"
(owr3.a = swr3).concat("1").concat("2")
p [owr3.a, swr3]
owr4 = Wr.new
swr4 = +"s"
((owr4.a = swr4) << "!").upcase!
p [owr4.a, swr4]
owr5 = Wr.new
swr5 = +"s"
twr5 = "#{(owr5.a = swr5) << "!" << "?"}"
p [owr5.a, swr5, twr5]
owr6 = Wr.new
swr6 = +"sab"
uwr6 = [(owr6.a = swr6).upcase, (owr6.a = swr6).size, (owr6.a = swr6).bytes, (owr6.a = swr6).chars, (owr6.a = swr6).start_with?("s")]
swr6 << "1"
p [owr6.a, swr6, uwr6]
nwr7 = ARGV.size == 0 ? nil : Wr.new
swr7 = +"s"
rwr7 = (nwr7&.a = swr7)&.<<("!")
p [rwr7, swr7]
mwr8 = Wr.new
swr8 = +"s"
rwr8 = (mwr8&.a = swr8)&.<<("!")
p [mwr8.a, swr8, rwr8]
oacc9 = Acc.new
sacc9 = +"s"
racc9 = ((oacc9.a = sacc9) << "!").freeze
p [racc9, racc9.equal?(sacc9), sacc9.frozen?, oacc9.a.frozen?]
oacc10 = Acc.new
sacc10 = +"s"
xacc10 = (oacc10.a = sacc10).freeze.freeze
p [xacc10.equal?(sacc10), xacc10.frozen?]
oacc11 = Acc.new
sacc11 = +"s"
[1, 2].each { |i| (oacc11.a = sacc11) << i.to_s }
p [sacc11, oacc11.a]
ost9 = S.new(+"x")
sst9 = +"s"
rst9 = ((ost9.a = sst9) << "!").freeze
p [rst9, rst9.equal?(sst9), sst9.frozen?, ost9.a.frozen?]
ost10 = S.new(+"x")
sst10 = +"s"
xst10 = (ost10.a = sst10).freeze.freeze
p [xst10.equal?(sst10), xst10.frozen?]
ost11 = S.new(+"x")
sst11 = +"s"
[1, 2].each { |i| (ost11.a = sst11) << i.to_s }
p [sst11, ost11.a]
owr9 = Wr.new
swr9 = +"s"
rwr9 = ((owr9.a = swr9) << "!").freeze
p [rwr9, rwr9.equal?(swr9), swr9.frozen?, owr9.a.frozen?]
owr10 = Wr.new
swr10 = +"s"
xwr10 = (owr10.a = swr10).freeze.freeze
p [xwr10.equal?(swr10), xwr10.frozen?]
owr11 = Wr.new
swr11 = +"s"
[1, 2].each { |i| (owr11.a = swr11) << i.to_s }
p [swr11, owr11.a]
