# A raising arm contributes no return value. Every returning arm still
# publishes its String for identity reads and direct or assigned mutation.
S = +"s"
def source = S
def pick_in(x) = case x; in Integer then S; in String then raise "bad"; end
p pick_in(1).equal?(S)
pick_in(1) << "i"
p S
held = pick_in(1)
held << "h"
p held.equal?(S)
p S
begin
  pick_in("x")
rescue RuntimeError => e
  p e.message
end

def pick_when(x) = case x; when Integer then S; when String then raise ArgumentError, "x"; end
p pick_when(1).equal?(S)
pick_when(1) << "w"
p S
p pick_when(false).equal?(nil)
begin
  pick_when("x")
rescue ArgumentError => e
  p e.message
end

def pick_if(x) = if x; source; else; fail; end
p pick_if(true).equal?(S)
pick_if(true) << "f"
p S
begin
  pick_if(false)
rescue RuntimeError
  puts "failed"
end

def pick_ternary(x) = x ? source : (raise "bad")
p pick_ternary(true).equal?(S)
pick_ternary(true) << "t"
p S

def pick_unless(x) = unless x; raise "bad"; else; source; end
p pick_unless(true).equal?(S)
pick_unless(true) << "u"
p S

def pick_elsif(x)
  if x == 0
    source
    raise "bad"
  elsif x == 1
    source
  else
    fail "bad"
  end
end
p pick_elsif(1).equal?(S)
pick_elsif(1) << "e"
p S

def pick_return(x)
  return case x; in Integer then source; else raise "bad"; end
end
p pick_return(1).equal?(S)
pick_return(1) << "r"
p S

# Begin, rescue and else values use the same tail walk.
def pick_rescue(x)
  begin
    raise "bad" unless x
    source
  rescue
    raise ArgumentError, "rescued"
  end
end
p pick_rescue(true).equal?(S)
pick_rescue(true) << "b"
p S
begin
  pick_rescue(false)
rescue ArgumentError => e
  p e.message
end

def pick_else(x)
  begin
    raise "bad" unless x
  rescue
    source
  else
    fail "else"
  end
end
p pick_else(false).equal?(S)
pick_else(false) << "l"
p S
begin
  pick_else(true)
rescue RuntimeError => e
  p e.message
end

# No arm returning a handle means there is no return handle to pick up.
def all_in(x) = case x; in Integer then raise "in"; else fail "in"; end
def all_when(x) = case x; when Integer then raise "when"; else fail "when"; end
def all_if(x) = if x; raise "if"; else fail "if"; end
def all_ternary(x) = x ? raise("ternary") : fail("ternary")
def all_begin = begin; raise "begin"; rescue; fail "begin"; end
begin; all_in(1).equal?(S); rescue RuntimeError => e; p e.message; end
begin; all_when(1).equal?(S); rescue RuntimeError => e; p e.message; end
begin; all_if(true).equal?(S); rescue RuntimeError => e; p e.message; end
begin; all_ternary(true).equal?(S); rescue RuntimeError => e; p e.message; end
begin; all_begin.equal?(S); rescue RuntimeError => e; p e.message; end
