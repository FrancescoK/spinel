# h[k] = v with a String-or-nil v, on a value of more than one class, once a
# class defines []=: the dispatch bound the boxed v to an sp_String * temp
# and the C did not build (#7305).
# spinel: share
class Rec
  attr_reader :last
  def []=(name, value)
    @last = value
  end
end

def store(params, name, v)
  if name.start_with?("[")
    params[name] = {} if params[name].nil?
    params[name] = store(params[name], name[1..].to_s, v)
  else
    params[name] = v
  end
  params
end

p store({}, "a", "1")
p store({}, "b", nil)
p store({}, "[c", "3")
r = Rec.new
store(r, "x", "val")
p r.last
store(r, "y", nil)
p r.last
