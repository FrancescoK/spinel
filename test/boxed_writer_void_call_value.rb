# A call to a method that never answers (its body raises NoMethodError, so
# it compiles to a C void function) passed to a writer reached through a
# boxed receiver: the statement, the value and the multiple-assignment forms
# each held the call in an sp_RbVal temp, and the C did not build ("invalid
# initializer"). The call now runs and raises, as it does in Ruby.
class Res
  attr_accessor :body
end
def evaluate(a)
  a.zork
end
def set_stmt(res)
  res.body = evaluate(res)
  nil
end
def set_value(res)
  x = (res.body = evaluate(res))
  x
end
def set_masgn(res)
  res.body, y = evaluate(res), 1
  y
end
res = Res.new
[res, "s"].each do |r|
  begin
    set_stmt(r)
  rescue NoMethodError => e
    p e.class
  end
  begin
    set_value(r)
  rescue NoMethodError => e
    p e.class
  end
  begin
    set_masgn(r)
  rescue NoMethodError => e
    p e.class
  end
end
p res.body
res.body = "ok"
p res.body
