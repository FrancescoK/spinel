# A case/in or `=>` with no else whose String subject is a variable holding
# the shared handle: the NoMatchingPatternError boxes the subject's handle,
# taken where the subject ran. Boxing the bytes the arms test put a copy in
# the error: a guard's in-place change was lost ("ab" for "ab!"). Reading
# the variable again at the raise would see a guard's rebinding.

def nm
  yield
rescue NoMatchingPatternError => e
  p e.class
  p e.message
end

def local_subject
  s = +"ab"
  u = s
  u << "c"
  nm { case s; in Integer then p 1; end }
  nm { case s; in Integer | Symbol => t then p t; end }
  nm { s => Integer }
  nm { case s; in [x] then p x; end }
  nm { case s; in {k:} then p k; end }
  p s
end

def guard_changes_subject
  s = +"ab"
  nm { case s; in String => t if (t << "!"; false) then p 0; end }
  p s
end

def guard_rebinds_subject
  s = +"ab"
  w = s
  w << "w"
  nm { case s; in String if (s = +"zz"; false) then p 0; end }
  p s
  p w
end

def binding_is_subject
  s = +"ab"
  case s
  in String => t
    p t.equal?(s)
    t << "1"
  end
  p s
end

def captured_subject
  s = +"cap"
  w = s
  w << "!"
  f = -> { case s; in Integer then 1; end }
  nm { f.call }
  g = proc { s = +"re"; nil }
  g.call
  nm { case s; in Integer then 1; end }
  p s
end

class Box
  def initialize; @s = +"iv"; end

  def run
    a = @s
    a << "!"
    nm { case @s; in Integer then 1; end }
    case @s
    in String => t
      t << "?"
    end
    p @s
  end
end

$g = +"glob"
def global_subject
  h = $g
  h << "1"
  nm { case $g; in Integer then 1; end }
  case $g
  in String => t
    t << "2"
  end
  p $g
end

def param_subject(x)
  nm { case x; in Integer then 1; end }
  case x
  in String => t
    t << "p"
  end
end

local_subject
guard_changes_subject
guard_rebinds_subject
binding_is_subject
captured_subject
Box.new.run
global_subject
v = +"pv"
param_subject(v)
p v
