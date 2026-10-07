# A module included into builtin classes and into Object, whose method
# calls super: in a Float, String, Integer, nil, true, Symbol, Array or
# Hash it reaches Object's method of that name with self as it is
# (activesupport's core_ext/object/json.rb includes its to_json so).
class Object
  def label(opt = nil) = "obj(#{self.inspect},#{opt.inspect})"
end
module Enc
  def label(opt = nil)
    opt ? super(opt) : "enc"
  end
end
class TrueClass; include Enc; end
class String; include Enc; end
class NilClass; include Enc; end
class Integer; include Enc; end
class Hash; include Enc; end
class Float; include Enc; end
class FalseClass; include Enc; end
class Array; include Enc; end
class Symbol; include Enc; end
values = [1.5, "s", 3, nil, true, false, :sym, [1, 2], { a: 1 }]
values.each { |v| p v.label }
values.each { |v| p v.label(:x) }
