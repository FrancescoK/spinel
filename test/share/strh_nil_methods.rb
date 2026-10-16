# spinel: share
# spinel: gc-minor
# Every method nil answers, called on a method's Array-or-nil value, answers
# what it does for nil when the value is nil and what it does for an Array
# when it is one.
def mk(f)
  t = +"t"
  a = [t]
  t << "!"
  f ? a : nil
end
n = mk(false)
r = mk(true)
def try(label)
  p [label, yield]
rescue NoMethodError, TypeError, ArgumentError => e
  p [label, e.class]
end
[n, r].each do |v|
  try(:not) { !v }
  try(:neq) { v != 1 }
  try(:and) { v & 1 }
  try(:cmp) { v <=> 1 }
  try(:eq) { v == nil }
  try(:eqq) { v === 1 }
  try(:xor) { v ^ 1 }
  try(:or) { v | 1 }
  try(:class) { v.class }
  try(:clone) { v.clone }
  try(:dup) { v.dup }
  try(:eql) { v.eql?(nil) }
  try(:equal) { v.equal?(nil) }
  try(:freeze) { v.dup.freeze.class }
  try(:frozen) { v.frozen? }
  try(:hash) { v.hash.class }
  try(:inspect) { v.inspect }
  try(:instance_of) { v.instance_of?(NilClass) }
  try(:is_a) { v.is_a?(Array) }
  try(:itself) { v.itself.class }
  try(:kind_of) { v.kind_of?(Object) }
  try(:nil) { v.nil? }
  try(:respond) { v.respond_to?(:size) }
  try(:send) { v.send(:class) }
  try(:tap) { v.tap { |x| 1 }.class }
  try(:then) { v.then { |x| 2 } }
  try(:to_a) { v.to_a }
  try(:to_h) { v.to_h }
  try(:to_s) { v.to_s }
  try(:interp) { "#{v}" }
  try(:size) { v.size }
  try(:first) { v.first }
  try(:join) { v.join("-") }
  try(:push) { v << +"z" }
end
# beside them an Array nothing here touches keeps the handle form
u = +"u"
plain = [u, +"o"]
plain << +"p"
plain.each { |e| e << "." }
u << "?"
p plain, u
