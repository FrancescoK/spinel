# Pattern tails publish the String returned by the selected arm. Failed
# patterns raise; written nil and empty arms still return nil.
S = +"s"
def source = S
def pick(x) = case x; in Integer then S; in String then S; end
p pick(1).equal?(S)
p pick("x").equal?(S)
p pick(1).object_id == S.object_id
pick(1) << "!"
p S
held = pick(1)
held << "p"
p held.equal?(S)
p S
begin
  pick(false)
rescue NoMatchingPatternError
  puts "no match"
end

def pick_else(x) = case x; in Integer then S; else S; end
p pick_else(1).equal?(S)
p pick_else(false).equal?(S)
pick_else(false) << "e"
p S

def pick_guard(x) = case x; in Integer if x > 0 then S; in String then S; else S; end
p pick_guard(1).equal?(S)
p pick_guard(0).equal?(S)
p pick_guard("x").equal?(S)
pick_guard(1) << "g"
p S
def pick_guard_no_else(x) = case x; in Integer if x > 0 then S; end
p pick_guard_no_else(1).equal?(S)
begin
  pick_guard_no_else(0)
rescue NoMatchingPatternError
  puts "guard failed"
end

def pick_nil(x)
  source
  case x
  in Integer then S
  in String then nil
  else nil
  end
end
p pick_nil(1).equal?(S)
p pick_nil("x").equal?(nil)
p pick_nil(false).object_id == nil.object_id
pick_nil(1) << "n"
p S
held_nil = pick_nil("x")
p held_nil.equal?(nil)

def pick_empty(x)
  source
  case x
  in Integer then S
  in String then
  else
  end
end
p pick_empty(1).equal?(S)
p pick_empty("x").equal?(nil)
p pick_empty(false).equal?(nil)

def pick_call(x) = case x; in Integer then source; in String then source; end
p pick_call(1).equal?(S)
p pick_call("x").equal?(S)
pick_call(1) << "c"
p S

def pick_return(x)
  return case x; in Integer then source; else source; end
end
p pick_return(1).equal?(S)
p pick_return(false).equal?(S)
pick_return(false) << "r"
p S

def pick_begin(x)
  begin
    case x; in Integer then S; end
  rescue NoMatchingPatternError
    case x; in String then S; else S; end
  end
end
p pick_begin(1).equal?(S)
p pick_begin("x").equal?(S)
pick_begin("x") << "b"
p S
held_begin = pick_begin(1)
held_begin << "h"
p held_begin.equal?(S)
p S

def pick_rescue(x)
  case x; in Integer then S; end
rescue NoMatchingPatternError
  case x; in String then S; else nil; end
end
p pick_rescue(1).equal?(S)
p pick_rescue("x").equal?(S)
p pick_rescue(false).equal?(nil)
pick_rescue("x") << "q"
p S
held_rescue = pick_rescue(1)
held_rescue << "j"
p held_rescue.equal?(S)
p S

# Ordinary case tails use the same pickup walk, including a missing else.
def pick_when(x) = case x; when 1 then S; end
held_when = pick_when(1)
held_when << "w"
p held_when.equal?(S)
p pick_when(0).equal?(nil)
p S
