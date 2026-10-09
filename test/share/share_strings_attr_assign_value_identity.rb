# spinel: gc-minor
# The identity of an attribute assignment's value: object_id and equal? name the
# very String, `itself`, `to_s` and `freeze` over it answer it, a Hash key is a
# copy, and a writer that changes the String before it returns it changes the
# one everybody holds. Each class has variables of its own.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
S = Struct.new(:a)
class Wr
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
class WAppend
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    v << "w"
  end
end

oacc1 = Acc.new
sacc1 = +"s"
p [(oacc1.a = sacc1).object_id == sacc1.object_id, (oacc1.a = sacc1).equal?(sacc1)]
tacc1 = (oacc1.a = sacc1)
p tacc1.object_id == sacc1.object_id
oacc2 = Acc.new
sacc2 = +"s"
racc2 = (oacc2.a = sacc2).itself.freeze
p [racc2.equal?(sacc2), racc2.frozen?, sacc2.frozen?]
oacc3 = Acc.new
sacc3 = +"s"
racc3 = (oacc3.a = sacc3).to_s.freeze
p [racc3.equal?(sacc3), racc3.frozen?]
oacc4 = Acc.new
sacc4 = +"s"
hacc4 = { (oacc4.a = sacc4) => 1 }
sacc4 << "x"
p [hacc4.keys[0], sacc4]
ost1 = S.new(+"x")
sst1 = +"s"
p [(ost1.a = sst1).object_id == sst1.object_id, (ost1.a = sst1).equal?(sst1)]
tst1 = (ost1.a = sst1)
p tst1.object_id == sst1.object_id
ost2 = S.new(+"x")
sst2 = +"s"
rst2 = (ost2.a = sst2).itself.freeze
p [rst2.equal?(sst2), rst2.frozen?, sst2.frozen?]
ost3 = S.new(+"x")
sst3 = +"s"
rst3 = (ost3.a = sst3).to_s.freeze
p [rst3.equal?(sst3), rst3.frozen?]
ost4 = S.new(+"x")
sst4 = +"s"
hst4 = { (ost4.a = sst4) => 1 }
sst4 << "x"
p [hst4.keys[0], sst4]
owr1 = Wr.new
swr1 = +"s"
p [(owr1.a = swr1).object_id == swr1.object_id, (owr1.a = swr1).equal?(swr1)]
twr1 = (owr1.a = swr1)
p twr1.object_id == swr1.object_id
owr2 = Wr.new
swr2 = +"s"
rwr2 = (owr2.a = swr2).itself.freeze
p [rwr2.equal?(swr2), rwr2.frozen?, swr2.frozen?]
owr3 = Wr.new
swr3 = +"s"
rwr3 = (owr3.a = swr3).to_s.freeze
p [rwr3.equal?(swr3), rwr3.frozen?]
owr4 = Wr.new
swr4 = +"s"
hwr4 = { (owr4.a = swr4) => 1 }
swr4 << "x"
p [hwr4.keys[0], swr4]
owa1 = WAppend.new
swa1 = +"s"
p [(owa1.a = swa1).object_id == swa1.object_id, (owa1.a = swa1).equal?(swa1)]
twa1 = (owa1.a = swa1)
p twa1.object_id == swa1.object_id
owa2 = WAppend.new
swa2 = +"s"
rwa2 = (owa2.a = swa2).itself.freeze
p [rwa2.equal?(swa2), rwa2.frozen?, swa2.frozen?]
owa3 = WAppend.new
swa3 = +"s"
rwa3 = (owa3.a = swa3).to_s.freeze
p [rwa3.equal?(swa3), rwa3.frozen?]
owa4 = WAppend.new
swa4 = +"s"
hwa4 = { (owa4.a = swa4) => 1 }
swa4 << "x"
p [hwa4.keys[0], swa4]
