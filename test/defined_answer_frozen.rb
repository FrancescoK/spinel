# defined? answers a frozen String, as CRuby does: the labels were rodata
# literals, which report frozen? false and accepted a mutation.

x = 1
p defined?(x).frozen?, defined?(x)
p defined?(String).frozen?, defined?(puts).frozen?, defined?(@a = 1).frozen?
p defined?(self).frozen?, defined?(nil).frozen?, defined?(1 + 1).frozen?
"ab" =~ /a/
p defined?($~).frozen?, defined?($1)
def m = defined?(yield)
p m { }.frozen?, m
h = {}
p defined?(h[:a]).frozen?
class S; def a = 1; end
class T < S; def a = defined?(super).frozen?; end
p T.new.a
s = defined?(x)
begin
  s << "x"
rescue FrozenError => e
  p e.class
end
