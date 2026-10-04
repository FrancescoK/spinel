# A String-or-nil argument handed to a poly dispatch whose name a class
# defines (`[]=`, a method) is held in the dispatch boxed, as its slot is.
class Rec
  def []=(name, value)
    @last = value
  end
  def put(name, value) = (@last = value; self)
  def last = @last
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

def put2(o, v)
  o.put("k", v)
  o
end

p store({}, "a", "1")
p store({}, "b", nil)
p store({}, "[c", "3")
r = Rec.new
p store(r, "x", "y").last
p store(r, "x", nil).last
p put2(Rec.new, "s").last, put2(Rec.new, nil).last
