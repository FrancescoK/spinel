# frozen_string_literal: true
# dup of a string held boxed (`fmt || FORMAT` with fmt nil) is a copy, not
# frozen, and a gsub! on it leaves the constant alone.
class T
  FORMAT = "a%ub"
  def f(fmt = nil)
    s = (fmt || FORMAT).dup
    s.gsub!(/(%[-+.\d]*)u/) { "#{$1}f" % 1.5 }
    s
  end
end
p T.new.f
p T::FORMAT
p T::FORMAT.frozen?
