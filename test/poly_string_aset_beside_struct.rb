# `s[i] = v` on a boxed String in a program that defines a Struct. Every
# Struct owns `[]=`, so the call goes to the user-class dispatch, which had
# no String arm: a String shared by two names fell to the default and the
# store was lost, and a plain one (a boxed String's cls_id is 0) took the
# first class's Struct arm and had the member written into its bytes. A
# boxed Integer or nil took the same arm and crashed.
P = Struct.new(:a)

# one String, two names: the store reaches both
s = +"hello"
t = nil
t ||= s
t[0] = "Q"
p [s, t]

def give(x) = yield(x)
a = +"hello"
give(a) { |y| y[0] = "J" }
p a

d = +"hello"
[d].each { |x| x[1] = "E" }
p d

e = +"hello"
h = { k: e }
h[:k][4] = "O"
p [e, h]

# a String nothing else names
u = [1, "x"].last
u = +"abc" if u
u[1] = "Z"
p u
v = [1, "x"].last
v = +"abc" if v
v[0] = "Y"
p v

def put_w(x) = (x[0] = "W"; x)
p put_w(+"pq")
p put_w(P.new(1).to_a)

# String and Regexp keys
w = +"hello"
x2 = nil
x2 ||= w
x2["ell"] = "ipp"
x2[/p+/] = "P"
p [w, x2]
y = [1, "x"].last
y = +"hello" if y
y["ll"] = "LL"
p y

# the Struct itself, and receivers with no `[]=`
st = [1, P.new(5)].last
st[0] = 9
p st
[5, :sym, nil, 2.5, true].each do |x|
  begin
    x[0] = 9
    p x
  rescue NoMethodError => err
    p [err.class, x]
  end
end

# a frozen String still refuses the store
f = [1, "lit"].last
begin
  f[0] = "L"
rescue FrozenError => err
  p err.class
end
p f
