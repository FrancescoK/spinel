# spinel: gc-minor
# The value of an attribute assignment as the receiver of a String mutator is
# the handle the assignment stored, so the mutation shows through the field and
# the right-hand side; and as the tail of a method through case, begin and
# rescue it is the one String too. Each class has variables and helpers of
# its own: a receiver of several classes stays refused.
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

def tailcase_acc(o, s, c)
  case c
  when 1 then o.a = s
  end
end
def tailbegin_acc(o, s)
  begin
    o.a = s
  rescue
    nil
  end
end
def tailcase_st(o, s, c)
  case c
  when 1 then o.a = s
  end
end
def tailbegin_st(o, s)
  begin
    o.a = s
  rescue
    nil
  end
end
def tailcase_wr(o, s, c)
  case c
  when 1 then o.a = s
  end
end
def tailbegin_wr(o, s)
  begin
    o.a = s
  rescue
    nil
  end
end

oacc_setbyte = Acc.new
sacc_setbyte = +"sab"
(oacc_setbyte.a = sacc_setbyte).setbyte(1, 90)
p [oacc_setbyte.a, sacc_setbyte, oacc_setbyte.a.frozen?, sacc_setbyte.frozen?, oacc_setbyte.a.encoding, sacc_setbyte.encoding]
oacc_slice = Acc.new
sacc_slice = +"sab"
(oacc_slice.a = sacc_slice).slice!(0)
p [oacc_slice.a, sacc_slice, oacc_slice.a.frozen?, sacc_slice.frozen?, oacc_slice.a.encoding, sacc_slice.encoding]
oacc_concat = Acc.new
sacc_concat = +"sab"
(oacc_concat.a = sacc_concat).concat("8")
p [oacc_concat.a, sacc_concat, oacc_concat.a.frozen?, sacc_concat.frozen?, oacc_concat.a.encoding, sacc_concat.encoding]
oacc_freeze = Acc.new
sacc_freeze = +"sab"
(oacc_freeze.a = sacc_freeze).freeze
p [oacc_freeze.a, sacc_freeze, oacc_freeze.a.frozen?, sacc_freeze.frozen?, oacc_freeze.a.encoding, sacc_freeze.encoding]
oacc_force = Acc.new
sacc_force = +"sab"
(oacc_force.a = sacc_force).force_encoding("ASCII-8BIT")
p [oacc_force.a, sacc_force, oacc_force.a.frozen?, sacc_force.frozen?, oacc_force.a.encoding, sacc_force.encoding]
oacc_scrub = Acc.new
sacc_scrub = +"sab"
(oacc_scrub.a = sacc_scrub).scrub!
p [oacc_scrub.a, sacc_scrub, oacc_scrub.a.frozen?, sacc_scrub.frozen?, oacc_scrub.a.encoding, sacc_scrub.encoding]
oacc_squeeze = Acc.new
sacc_squeeze = +"sab"
(oacc_squeeze.a = sacc_squeeze).squeeze!
p [oacc_squeeze.a, sacc_squeeze, oacc_squeeze.a.frozen?, sacc_squeeze.frozen?, oacc_squeeze.a.encoding, sacc_squeeze.encoding]
oc_acc = Acc.new
sc_acc = +"s"
rc_acc = tailcase_acc(oc_acc, sc_acc, 1)
rc_acc << "1"
p [oc_acc.a, sc_acc, rc_acc]
ob_acc = Acc.new
sb_acc = +"s"
rb_acc = tailbegin_acc(ob_acc, sb_acc)
rb_acc << "2"
p [ob_acc.a, sb_acc, rb_acc]
ost_setbyte = S.new(+"x")
sst_setbyte = +"sab"
(ost_setbyte.a = sst_setbyte).setbyte(1, 90)
p [ost_setbyte.a, sst_setbyte, ost_setbyte.a.frozen?, sst_setbyte.frozen?, ost_setbyte.a.encoding, sst_setbyte.encoding]
ost_slice = S.new(+"x")
sst_slice = +"sab"
(ost_slice.a = sst_slice).slice!(0)
p [ost_slice.a, sst_slice, ost_slice.a.frozen?, sst_slice.frozen?, ost_slice.a.encoding, sst_slice.encoding]
ost_concat = S.new(+"x")
sst_concat = +"sab"
(ost_concat.a = sst_concat).concat("8")
p [ost_concat.a, sst_concat, ost_concat.a.frozen?, sst_concat.frozen?, ost_concat.a.encoding, sst_concat.encoding]
ost_freeze = S.new(+"x")
sst_freeze = +"sab"
(ost_freeze.a = sst_freeze).freeze
p [ost_freeze.a, sst_freeze, ost_freeze.a.frozen?, sst_freeze.frozen?, ost_freeze.a.encoding, sst_freeze.encoding]
ost_force = S.new(+"x")
sst_force = +"sab"
(ost_force.a = sst_force).force_encoding("ASCII-8BIT")
p [ost_force.a, sst_force, ost_force.a.frozen?, sst_force.frozen?, ost_force.a.encoding, sst_force.encoding]
ost_scrub = S.new(+"x")
sst_scrub = +"sab"
(ost_scrub.a = sst_scrub).scrub!
p [ost_scrub.a, sst_scrub, ost_scrub.a.frozen?, sst_scrub.frozen?, ost_scrub.a.encoding, sst_scrub.encoding]
ost_squeeze = S.new(+"x")
sst_squeeze = +"sab"
(ost_squeeze.a = sst_squeeze).squeeze!
p [ost_squeeze.a, sst_squeeze, ost_squeeze.a.frozen?, sst_squeeze.frozen?, ost_squeeze.a.encoding, sst_squeeze.encoding]
oc_st = S.new(+"x")
sc_st = +"s"
rc_st = tailcase_st(oc_st, sc_st, 1)
rc_st << "1"
p [oc_st.a, sc_st, rc_st]
ob_st = S.new(+"x")
sb_st = +"s"
rb_st = tailbegin_st(ob_st, sb_st)
rb_st << "2"
p [ob_st.a, sb_st, rb_st]
owr_setbyte = Wr.new
swr_setbyte = +"sab"
(owr_setbyte.a = swr_setbyte).setbyte(1, 90)
p [owr_setbyte.a, swr_setbyte, owr_setbyte.a.frozen?, swr_setbyte.frozen?, owr_setbyte.a.encoding, swr_setbyte.encoding]
owr_slice = Wr.new
swr_slice = +"sab"
(owr_slice.a = swr_slice).slice!(0)
p [owr_slice.a, swr_slice, owr_slice.a.frozen?, swr_slice.frozen?, owr_slice.a.encoding, swr_slice.encoding]
owr_concat = Wr.new
swr_concat = +"sab"
(owr_concat.a = swr_concat).concat("8")
p [owr_concat.a, swr_concat, owr_concat.a.frozen?, swr_concat.frozen?, owr_concat.a.encoding, swr_concat.encoding]
owr_freeze = Wr.new
swr_freeze = +"sab"
(owr_freeze.a = swr_freeze).freeze
p [owr_freeze.a, swr_freeze, owr_freeze.a.frozen?, swr_freeze.frozen?, owr_freeze.a.encoding, swr_freeze.encoding]
owr_force = Wr.new
swr_force = +"sab"
(owr_force.a = swr_force).force_encoding("ASCII-8BIT")
p [owr_force.a, swr_force, owr_force.a.frozen?, swr_force.frozen?, owr_force.a.encoding, swr_force.encoding]
owr_scrub = Wr.new
swr_scrub = +"sab"
(owr_scrub.a = swr_scrub).scrub!
p [owr_scrub.a, swr_scrub, owr_scrub.a.frozen?, swr_scrub.frozen?, owr_scrub.a.encoding, swr_scrub.encoding]
owr_squeeze = Wr.new
swr_squeeze = +"sab"
(owr_squeeze.a = swr_squeeze).squeeze!
p [owr_squeeze.a, swr_squeeze, owr_squeeze.a.frozen?, swr_squeeze.frozen?, owr_squeeze.a.encoding, swr_squeeze.encoding]
oc_wr = Wr.new
sc_wr = +"s"
rc_wr = tailcase_wr(oc_wr, sc_wr, 1)
rc_wr << "1"
p [oc_wr.a, sc_wr, rc_wr]
ob_wr = Wr.new
sb_wr = +"s"
rb_wr = tailbegin_wr(ob_wr, sb_wr)
rb_wr << "2"
p [ob_wr.a, sb_wr, rb_wr]
