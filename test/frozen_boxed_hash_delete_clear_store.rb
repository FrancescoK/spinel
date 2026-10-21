# spinel: share
# spinel: gc-stress
h = [{ a: 1 }.freeze, 0][0]
p((begin; h.delete(:a); "no raise"; rescue => e; e.class; end))
p((begin; h.clear; "no raise"; rescue => e; e.class; end))
p [h, h.frozen?]

h = [{"s"=>1, a:2}.freeze, 0][0]
begin; h["s"] = 9; rescue FrozenError => e; p [e.class,e.message,e.receiver.equal?(h)]; end
p h
begin; h.store(:a, 8); rescue FrozenError => e; p [e.class,e.message,e.receiver.equal?(h)]; end
p h

# aliases
h=[{a:1}.freeze,0][0];a=h
begin;h.delete(:a);rescue FrozenError=>e;p [e.message,e.receiver.equal?(a)];end
begin;h.clear;rescue FrozenError=>e;p [e.message,e.receiver.equal?(a)];end
p [h,a,h.equal?(a),a.frozen?]

# default
h=Hash.new(7);h[:a]=1;h.freeze;b=[h,0][0]
begin;b.clear;rescue FrozenError=>e;p [e.class,e.message];end
begin;b.delete(:none);rescue FrozenError=>e;p [e.class,e.message];end
p [b,b[:none],b.frozen?]

# empty_hash
h=[{}.freeze,0][0]
begin;h.delete(:none);rescue FrozenError=>e;p [e.class,e.message];end
begin;h.clear;rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
p [h,h.frozen?]

# missing_key
h=[{a:1}.freeze,0][0]
begin;h.delete(:none);rescue FrozenError=>e;p [e.message,e.receiver.equal?(h)];end
p [h,h.frozen?]

# str_poly
h=[{"a"=>1,"b"=>"x"}.freeze,0][0]
begin;h.delete("a");rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
begin;h.delete("missing");rescue FrozenError=>e;p [e.class,e.message];end
begin;h.clear;rescue FrozenError=>e;p [e.class,e.message];end
p h

# receiver_order
hs=[{a:1}.freeze,{b:2}.freeze,0];i=-1
begin;hs[(i+=1)].clear;rescue FrozenError=>e;p [i,e.class,e.message];end
begin;hs[(i+=1)].delete(:b);rescue FrozenError=>e;p [i,e.class,e.message];end
p hs

# block_guard
h=[{a:1}.freeze,0][0];calls=0
begin;h.delete(:none){calls+=1;9};rescue FrozenError=>e;p [e.class,e.message];end
p [h,calls]

# parameter
def try_remove(h)
 begin;h.delete(:a);rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
 begin;h.clear;rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
end
h=[{a:1}.freeze,0][0];try_remove(h);p h

# native_variants
hs=[{1=>2}.freeze,{1=>"x"}.freeze,{"a"=>2}.freeze,{"a"=>"x"}.freeze,{a:2}.freeze,{"a"=>1,b:"x"}.freeze]
ks=[1,1,"a","a",:a,"a"]
hs.each_with_index do |h,i|
 begin;h.delete(ks[i]);rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
 begin;h.clear;rescue FrozenError=>e;p [e.class,e.message,e.receiver.equal?(h)];end
 p [h,h.frozen?]
end

# nonfrozen
h=[{a:1,b:2},0][0];p h.delete(:a);p h.delete(:none);p h.clear.equal?(h);p h
s=[{"a"=>1,"b"=>"x"},0][0];p s.delete("a");p s.clear;p s
m=[{"a"=>1,b:2},0][0];p m["a"]=9;p m.store(:b,8);p m

# nonhash_controls
a=[[1,2],0][0];p a.delete(1);p a.clear;p a
s=["abc",0][0];p s.delete("b")


# []= with a Symbol or String key on a frozen boxed Hash
y = [{a: 1}.freeze, 0][0]
begin; y[:a] = 2; rescue FrozenError => e; p [e.class, e.message]; end
begin; y[:new] = 2; rescue FrozenError => e; p [e.class, e.message]; end
s = [{"a" => 1, "b" => "x"}.freeze, 0][0]
begin; s["new"] = 1; rescue FrozenError => e; p [e.class, e.message]; end
m = [{"a" => 1, b: "x"}.freeze, 0][0]
begin; m[:b] = "y"; rescue FrozenError => e; p [e.class, e.message]; end
e0 = [{}.freeze, 0][0]
begin; e0["a"] = 1; rescue FrozenError => e; p [e.class, e.message]; end
p [y, s, m, e0]
