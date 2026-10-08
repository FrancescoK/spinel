# Conditional tails forward a callee's shared String handle for identity
# and mutation. Nil arms keep nil even after a call published a handle.
S = +"s"
def a = S
def b = S
def choose(f) = f ? a : b
p choose(true).equal?(S)
p choose(false).equal?(S)
choose(false) << "!"
p S

def choose_if(f)
  if f
    a
  else
    b
  end
end
p choose_if(true).equal?(S)
p choose_if(false).equal?(S)
choose_if(true) << "i"
p S

def choose_case(f)
  case f
  when 1
    a
  when 2
    b
  else
    a
  end
end
p choose_case(1).equal?(S)
p choose_case(2).equal?(S)
p choose_case(3).equal?(S)
choose_case(2) << "c"
p S

def choose_unless(f)
  unless f
    b
  else
    a
  end
end
p choose_unless(true).equal?(S)
p choose_unless(false).equal?(S)
choose_unless(false) << "u"
p S

def choose_nested(f, g) = f ? (g ? a : b) : (g ? b : a)
p choose_nested(true, true).equal?(S)
p choose_nested(true, false).equal?(S)
p choose_nested(false, true).equal?(S)
p choose_nested(false, false).equal?(S)
choose_nested(false, true) << "n"
p S

def maybe(f)
  a
  f ? b : nil
end
p maybe(true).equal?(S)
p maybe(false).equal?(nil)
p nil.equal?(maybe(false))
p maybe(false).object_id == nil.object_id
p maybe(false).__id__ == nil.__id__
p maybe(false).frozen?
maybe(true) << "m"
p S

def maybe_unless(f)
  a
  b unless f
end
p maybe_unless(false).equal?(S)
p maybe_unless(true).equal?(nil)
maybe_unless(false) << "v"
p S

def maybe_case(f)
  a
  case f
  when true
    b
  end
end
p maybe_case(true).equal?(S)
p maybe_case(false).equal?(nil)
maybe_case(true) << "w"
p S

def maybe_nested(f, g)
  a
  if f
    if g
      nil
    else
      b
    end
  elsif g
    a
  end
end
p maybe_nested(true, true).equal?(nil)
p maybe_nested(true, false).equal?(S)
p maybe_nested(false, true).equal?(S)
p maybe_nested(false, false).equal?(nil)
maybe_nested(true, false) << "x"
p S

def choose_return(f)
  return f ? a : b
end
p choose_return(true).equal?(S)
p choose_return(false).equal?(S)
choose_return(false) << "r"
p S

# The same tail walk handles parentheses and begin/rescue arms.
def choose_rescue(f)
  begin
    raise "rescue" unless f
    a
  rescue
    b
  end
end
p choose_rescue(true).equal?(S)
p choose_rescue(false).equal?(S)
choose_rescue(false) << "e"
p S

# Visiting a recursive arm must terminate; a fresh arm is not a handle.
def recursive(f) = f ? a : recursive(true)
p recursive(false)
def fresh_choice(f)
  a
  f ? b : +"fresh"
end
p fresh_choice(false).equal?(S)
p fresh_choice(false)
p S
