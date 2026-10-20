# spinel: gc-stress
# The identity of a conditional (`?:`, if, unless, case) or of a boxed
# receiver's call whose arms answer a String is the String its taken arm
# hands on. equal? and object_id read it as the arm's bytes, a copy of a
# handle's, so `(c ? s : t).equal?(t)` answered false where t is taken, on
# either side of equal?, through each arm kind and in a nested
# conditional, and `px.pick(s).equal?(s)` answered false where pick
# answers its argument. Both now ask the box the conditional or the
# dispatch answers, which holds the arm's handle.
$g = +"glob"
class Holder
  attr_reader :r
  def initialize = (@iv = +"iv"; @r = +"rd")
  def id(x) = x
  def run(c)
    s = +"abc"; t = +"zz"; a = [s]; f = "lit"
    p [(c ? s : t).equal?(t), (c ? s : t).equal?(s), t.equal?(c ? s : t)]
    p [(if c then s else t end).equal?(t), (unless c then s else t end).equal?(s)]
    p [(case c when true then s else t end).equal?(t)]
    p [(c ? @iv : t).equal?(@iv), (c ? $g : t).equal?($g), (c ? r : t).equal?(@r)]
    p [(c ? id(s) : t).equal?(s), (c ? a[0] : t).equal?(s), (c ? s.itself : t).equal?(s)]
    p [(c ? (c ? s : t) : t).equal?(s), (c ? t : (c ? t : s)).equal?(s)]
    p [(c ? f : t).equal?(f), (c ? +"x" : t).equal?(t), (c ? s : nil).equal?(nil)]
    p [(c ? s : t).object_id == s.object_id, (c ? s : t).object_id == t.object_id]
    p [(unless c then s else t end).object_id == t.object_id]
    s << "!"
    p [s, t, (c ? s : t)]
  end
end
Holder.new.run(true)
Holder.new.run(false)

class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
[0, 1].each do |k|
  px = k == 0 ? PA.new : PB.new
  s = +"abc"; u = +"uu"
  p [px.pick(s).equal?(s), s.equal?(px.pick(s)), px.pick(u).equal?(s)]
  p px.pick(s).object_id == s.object_id
  r = px.pick(s)
  s << "!"
  p [r, r.equal?(s)]
end
