# A key or value a hash parameter's variant cannot hold widens the caller's
# hash, and an element write through a boxed array parameter reaches the
# caller's array.

def put_sym(h); h["k"] = :s; h; end
def store_str(h); h.store("k", "v"); end
def or_sym(h); h["k"] ||= :z; end
def wrap(h); put_sym(h); end

x = {"a" => 1}; put_sym(x); p x
y = {"a" => 1}; store_str(y); p y
z = {"a" => 1}; or_sym(z); p z
p put_sym({"lit" => 1})
$gh = {"a" => 1}; put_sym($gh); p $gh
w = {"a" => 1}; wrap(w); p w
n = Hash.new(0); n["a"] = 1; put_sym(n); p n
e = {}; e["a"] = 1; put_sym(e); p e

class HashHolder
  attr_reader :h
  def initialize; @h = {"a" => 1}; put_sym(@h); end
end
p HashHolder.new.h

def put_any(h); h["k"] = :s; end
si = {"a" => 1}; ss = {"b" => "q"}; put_any(si); put_any(ss); p si, ss

def set0(arr); arr[0] = "s"; end
a = [1, 2]; b = ["x"]; set0(a); set0(b); p a, b
f = [1.5]; set0(f); p f
$ga = [1]; set0($ga); p $ga

class ArrHolder
  attr_reader :a
  def initialize; @a = [1]; set0(@a); end
end
p ArrHolder.new.a

def via(arr); set0(arr); end
v = [7, 8]; via(v); p v

def app(arr); arr << "s"; end
pa = [1, 2]; pb = ["x"]; app(pa); app(pb); p pa, pb
