# A call already proven to raise NoMethodError, used as a value where a temp
# holds it: the receiver of a block call, and the value of an attribute
# assignment on a receiver of two classes. The temp was declared `void`
# and the C did not build (#6213); the raise now fires at run time.
class Setting
  attr_accessor :data
end
class Rule
  attr_accessor :data
end
def pick(n) = n.even? ? Setting.new : Rule.new

begin
  nil.create(:order).tap { |order| p order }
rescue NoMethodError => e
  p e.message
end

s = pick(ARGV.size)
begin
  s.data = (s.data || {}).merge(lang: "en").deep_stringify_keys
rescue NoMethodError => e
  p e.message
end
p s.data
s.data = {lang: "ja"}
p s.data
