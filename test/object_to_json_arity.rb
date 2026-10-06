# Object#to_json takes an optional state and nothing more: a second
# argument is CRuby's ArgumentError. The call answered as though the extra
# argument were not there.
require "json"
class Pt
  def initialize(x); @x = x; end
  def to_s; "pt#{@x}"; end
end
o = Pt.new(1)
p o.to_json
p o.to_json(nil)
begin
  o.to_json(nil, 2)
  p :no_error
rescue ArgumentError => e
  p e.message
end
p [1, 2].to_json
p({a: 1}.to_json)
