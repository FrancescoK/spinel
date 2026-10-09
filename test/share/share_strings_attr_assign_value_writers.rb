# spinel: gc-minor
# The value of an attribute assignment is the String the writer was handed,
# whatever the writer returns: the stored String, a different String, nil or
# self. It is kept in a local, a global and an instance variable and appended
# to, and the field names the same String. Each class has variables of its own.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
S = Struct.new(:a)
class WStore
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
  end
end
class WOther
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
    +"other"
  end
end
class WNil
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
    nil
  end
end
class WSelf
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
    self
  end
end

class WAppend
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
    v << "w"
  end
end
class WUpcase
  def initialize = (@a = +"x")
  def a = @a
  def a=(v)
    @a = v
    v.upcase!
    v
  end
end
class Keep_acc
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
class Keep_st
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
class Keep_wstore
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
class Keep_wother
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
class Keep_wnil
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
class Keep_wself
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end

class Keep_wappend
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end

class Keep_wupcase
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end

o_acc = Acc.new
b_acc = (o_acc.a = +"lit")
b_acc << "!"
p [b_acc, o_acc.a, b_acc.equal?(o_acc.a)]
og_acc = Acc.new
$g_acc = (og_acc.a = +"lit")
$g_acc << "?"
p [$g_acc, og_acc.a]
om_acc = Acc.new
p [Keep_acc.new.set(om_acc), om_acc.a]
os_acc = Acc.new
s_acc = +"s"
r_acc = (os_acc.a = s_acc)
r_acc << "1"
p [r_acc, s_acc, os_acc.a]
o_st = S.new(+"x")
b_st = (o_st.a = +"lit")
b_st << "!"
p [b_st, o_st.a, b_st.equal?(o_st.a)]
og_st = S.new(+"x")
$g_st = (og_st.a = +"lit")
$g_st << "?"
p [$g_st, og_st.a]
om_st = S.new(+"x")
p [Keep_st.new.set(om_st), om_st.a]
os_st = S.new(+"x")
s_st = +"s"
r_st = (os_st.a = s_st)
r_st << "1"
p [r_st, s_st, os_st.a]
o_wstore = WStore.new
b_wstore = (o_wstore.a = +"lit")
b_wstore << "!"
p [b_wstore, o_wstore.a, b_wstore.equal?(o_wstore.a)]
og_wstore = WStore.new
$g_wstore = (og_wstore.a = +"lit")
$g_wstore << "?"
p [$g_wstore, og_wstore.a]
om_wstore = WStore.new
p [Keep_wstore.new.set(om_wstore), om_wstore.a]
os_wstore = WStore.new
s_wstore = +"s"
r_wstore = (os_wstore.a = s_wstore)
r_wstore << "1"
p [r_wstore, s_wstore, os_wstore.a]
o_wother = WOther.new
b_wother = (o_wother.a = +"lit")
b_wother << "!"
p [b_wother, o_wother.a, b_wother.equal?(o_wother.a)]
og_wother = WOther.new
$g_wother = (og_wother.a = +"lit")
$g_wother << "?"
p [$g_wother, og_wother.a]
om_wother = WOther.new
p [Keep_wother.new.set(om_wother), om_wother.a]
os_wother = WOther.new
s_wother = +"s"
r_wother = (os_wother.a = s_wother)
r_wother << "1"
p [r_wother, s_wother, os_wother.a]
o_wnil = WNil.new
b_wnil = (o_wnil.a = +"lit")
b_wnil << "!"
p [b_wnil, o_wnil.a, b_wnil.equal?(o_wnil.a)]
og_wnil = WNil.new
$g_wnil = (og_wnil.a = +"lit")
$g_wnil << "?"
p [$g_wnil, og_wnil.a]
om_wnil = WNil.new
p [Keep_wnil.new.set(om_wnil), om_wnil.a]
os_wnil = WNil.new
s_wnil = +"s"
r_wnil = (os_wnil.a = s_wnil)
r_wnil << "1"
p [r_wnil, s_wnil, os_wnil.a]
o_wself = WSelf.new
b_wself = (o_wself.a = +"lit")
b_wself << "!"
p [b_wself, o_wself.a, b_wself.equal?(o_wself.a)]
og_wself = WSelf.new
$g_wself = (og_wself.a = +"lit")
$g_wself << "?"
p [$g_wself, og_wself.a]
om_wself = WSelf.new
p [Keep_wself.new.set(om_wself), om_wself.a]
os_wself = WSelf.new
s_wself = +"s"
r_wself = (os_wself.a = s_wself)
r_wself << "1"
p [r_wself, s_wself, os_wself.a]
o_wappend = WAppend.new
b_wappend = (o_wappend.a = +"lit")
b_wappend << "!"
p [b_wappend, o_wappend.a, b_wappend.equal?(o_wappend.a)]
og_wappend = WAppend.new
$g_wappend = (og_wappend.a = +"lit")
$g_wappend << "?"
p [$g_wappend, og_wappend.a]
om_wappend = WAppend.new
p [Keep_wappend.new.set(om_wappend), om_wappend.a]
os_wappend = WAppend.new
s_wappend = +"s"
r_wappend = (os_wappend.a = s_wappend)
r_wappend << "1"
p [r_wappend, s_wappend, os_wappend.a]
o_wupcase = WUpcase.new
b_wupcase = (o_wupcase.a = +"lit")
b_wupcase << "!"
p [b_wupcase, o_wupcase.a, b_wupcase.equal?(o_wupcase.a)]
og_wupcase = WUpcase.new
$g_wupcase = (og_wupcase.a = +"lit")
$g_wupcase << "?"
p [$g_wupcase, og_wupcase.a]
om_wupcase = WUpcase.new
p [Keep_wupcase.new.set(om_wupcase), om_wupcase.a]
os_wupcase = WUpcase.new
s_wupcase = +"s"
r_wupcase = (os_wupcase.a = s_wupcase)
r_wupcase << "1"
p [r_wupcase, s_wupcase, os_wupcase.a]
