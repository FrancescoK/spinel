# `x[k] = v` on a boxed receiver, with no user class owning `[]=`. A String
# receiver with a String or Regexp key lost the store (sp_poly_set_str and
# sp_poly_set_poly have no String arm), and a Symbol, which has `[]` but no
# `[]=`, took the store silently where CRuby raises NoMethodError.
def mk = [1, "x"].last

t = mk; t = +"hello" if t
t["ell"] = "ipp"
p t
t = mk; t = +"hello" if t
t[/l+/] = "L"
p t
t = mk; t = +"hello" if t
t[1] = "E"
p t
t = mk; t = +"hello" if t
begin
  t["zz"] = "q"
rescue IndexError => e
  p e.message
end
begin
  t[/z+/] = "q"
rescue IndexError => e
  p e.message
end

# one String under two names
s = +"hello"
u = nil
u ||= s
u["ell"] = "ELL"
p [s, u]

# a Hash still stores under the key
h = [1, {}].last
h["k"] = 1
p h

# receivers with no `[]=`
[5, :sym, nil, 2.5, true].each do |x|
  [0, "k", :k].each do |key|
    begin
      x[key] = 9
      p x
    rescue NoMethodError => e
      p [e.class, x]
    end
  end
end
