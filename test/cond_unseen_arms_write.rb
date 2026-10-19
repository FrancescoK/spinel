# A conditional whose every arm is an ARGV element, an ENV read, a new
# String or nil hands on a String no other name holds: a variable's write
# takes it, and a second name that changes it in place changes that one.

def pick = ARGV.size > 3 ? +"p" : nil

s = ARGV[0] || +"abc"
t = s
t << "!"
p s, t, s.equal?(t)

u = ARGV.size > 5 ? ARGV[0] : +"xyz"
v = u
v << "?"
p u, v

w = pick || +"def"
x = w
x << "#"
p w, x

y = case ARGV.size
    when 7 then ARGV[0]
    else +"case"
    end
z = y
z << "%"
p y, z

e = ENV["SPINEL_COND_UNSEEN_UNSET"] || +"env"
f = e
f << "&"
p e, f

model = ARGV[2] || "c128"
other = model
begin
  other << "x"
rescue FrozenError => err
  p err.class
end
p model, model.frozen?, other.equal?(model)
