# UnboundMethod#bind_call(obj, args...) binds the arguments after obj as
# bind(obj).call(args...) does, by the direct call's plan (arg_layout): a
# count judged in CRuby's words, optionals, a rest with its posts, a splat
# anywhere, required and optional keywords, a `**kwrest` or `**nil`, a `**`
# of every kind, and a block, literal or `&`, into a target keeping `&b` or
# one that yields. obj must be an instance of the method's owner (any
# object, for a module's), for bind_call and for bind. bind_call took each
# argument as one parameter and refused the rest, and passed no block to a
# `&b` target, whose C call was one argument short; neither checked obj.
# spinel: gc-minor
module Tag
  def tag(a, b = :d) = [:tag, a, b]
end
class K
  include Tag
  def initialize(n = 1) = (@n = n)
  def pos(a, b = @n, *r, c) = [a, b, r, c]
  def kws(a, k:, j: 2, **o) = [a, k, j, o]
  def kwo(a = 0, k: 1) = [a, k]
  def nokw(a, **nil) = [a]
  def blk(a, &b) = [a, (b ? b.call(a) : :none)]
  def yl(a) = block_given? ? yield(a) : :noblk
  def set(a) = (@n = a; nil)
end
class S < K; end
class R; end

# positionals: optionals default on obj, rest and post, splats anywhere
um = K.instance_method(:pos)
s = [2, 3]
e = []
p um.bind_call(K.new(9), 1, 4)
p um.bind_call(K.new(9), *s)
p um.bind_call(K.new, 1, *s, 5)
p um.bind_call(K.new, *e, 1, *[2, 3], 4, *e)
p((um.bind_call(K.new, *e, 1) rescue $!))
p((um.bind_call(K.new) rescue $!))

# keywords: required, optional, `**kwrest`, `**` of each kind
km = K.instance_method(:kws)
h = {k: 1, z: 3}
p km.bind_call(K.new, 0, k: 5, j: 6)
p km.bind_call(K.new, 0, **h, j: 7)
p km.bind_call(K.new, 0, "s" => 1, k: 2)
p km.bind_call(K.new, *[0], **[{k: 4}, 0][0])
p((km.bind_call(K.new, 0) rescue $!))
p((km.bind_call(K.new, 0, **nil) rescue $!))
p((km.bind_call(K.new, 0, **{}) rescue $!))
p((km.bind_call(K.new, 0, **true) rescue $!))
p((K.instance_method(:kwo).bind_call(K.new, 1, z: 2) rescue $!))
p((K.instance_method(:kwo).bind_call(K.new, "s" => 2) rescue $!))
p K.instance_method(:kwo).bind_call(K.new, k: 2, k: 3)
p((K.instance_method(:kwo).bind_call(K.new, 1, 2, 3) rescue $!))
p K.instance_method(:nokw).bind_call(K.new, {k: 1})
p K.instance_method(:nokw).bind_call(K.new, 1, **nil)
p((K.instance_method(:nokw).bind_call(K.new, 1, k: 1) rescue $!))

# a block, literal or `&`, into `&b` and into a target that yields
pr = proc { |x| x * 3 }
bm = K.instance_method(:blk)
p bm.bind_call(K.new, 4)
p bm.bind_call(K.new, 5) { |x| x + 1 }
p bm.bind_call(K.new, 6, &pr)
p K.instance_method(:yl).bind_call(K.new, 4)
p K.instance_method(:yl).bind_call(K.new, 4) { |x| x * 10 }
p K.instance_method(:yl).bind_call(K.new, 4, &pr)

# the owner: a module's method, an inherited one, a subclass receiver, and
# obj of the wrong class after the arguments ran
p Tag.instance_method(:tag).bind_call(K.new, 1)
p Tag.instance_method(:tag).bind_call(R.new, 2, 3)
p S.instance_method(:pos).bind_call(S.new(4), 1, 2)
p K.instance_method(:kws).bind_call(S.new, 1, k: 2)
p((K.instance_method(:pos).bind_call(R.new, (puts "ran"; 1), 2) rescue $!))
k = K.new
p K.instance_method(:set).bind_call(k, 7), k.pos(0, 1)

# bind checks the owner the same way, when it binds: a Method of the wrong
# receiver is never made, called or not
p((K.instance_method(:pos).bind(R.new).call(1, 2) rescue $!))
begin
  K.instance_method(:pos).bind(R.new)
  puts "not reached"
rescue TypeError => e
  p e
end
bt = Tag.instance_method(:tag).bind(R.new)
bs = K.instance_method(:pos).bind(S.new(6))
p bs.call(1, 2), bt.call(3), S.instance_method(:kws).bind(K.new).call(1, k: 2)

# fresh receivers and arguments that allocate, collected mid-call under
# SPINEL_GC_STRESS
r = (1..3).map do |i|
  K.instance_method(:kws).bind_call(K.new, "a" * (i * 8), k: [i] * 4, **{z: "b" * 16}) +
    K.instance_method(:pos).bind_call(K.new(i), *["c" * 8, "d" * 8], "e" * 8) +
    K.instance_method(:blk).bind_call(K.new, "f" * 8) { |x| x + "g" }
end
p r
