# An implicit append tail publishes its receiver's handle. Calls returning
# it keep that handle through a conditional or an explicit return too.
def grow(s) = s << "!"
def grow_if(s, yes) = if yes; grow(s); else; raise "if"; end
def grow_case(s, x)
  case x
  in Integer then grow(s)
  else raise "case"
  end
end
def grow_return(s)
  return grow(s)
end
def grow_rescue(s, yes)
  raise "body" unless yes
  grow(s)
rescue
  raise "rescue"
end
s = +"s"
t = s
r = grow(s)
p r.equal?(s)
r << "a"
p t
p grow_if(s, true).equal?(s)
grow_if(s, true) << "f"
p t
p grow_case(s, 1).equal?(s)
grow_case(s, 1) << "p"
p t
p grow_return(s).equal?(s)
grow_return(s) << "e"
p t
p grow_rescue(s, true).equal?(s)
grow_rescue(s, true) << "z"
p t
begin; grow_if(s, false); rescue RuntimeError => e; p e.message; end
begin; grow_case(s, "x"); rescue RuntimeError => e; p e.message; end
begin; grow_rescue(s, false); rescue RuntimeError => e; p e.message; end
