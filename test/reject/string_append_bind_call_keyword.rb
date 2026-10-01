# A String passed by keyword through `bind_call` to a method that appends
# to that keyword: the method's keyword is the shared handle, but the
# caller's String is not pulled into it through `bind_call`, so the call
# would hand the method a fresh copy and the append would not reach `s`
# (CRuby prints "a!"). Refused at compile time until it can be shared (#6179).
class Box
  def fill(k:) = (k << "!")
end
s = +"a"
Box.instance_method(:fill).bind_call(Box.new, k: s)
p s
