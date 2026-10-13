# Compiled with --defer-refusals: an attr call whose splat the compiler
# cannot read (a constant changed before it, a local) would declare
# nothing, so it is refused, and raises NotImplementedError where the class
# body runs. Without the flag it is refused.
# spinel: defer-refusals: 3:start true true after
puts "start"
begin
  class C
    FLAGS = %i[a b]
    FLAGS << :c
    attr_accessor(*FLAGS)
  end
rescue NotImplementedError => e
  puts e.message.include?("attr_accessor with a splat")
end
begin
  class E
    names = [:q]
    attr_reader(*names)
  end
rescue NotImplementedError => e
  puts e.message.include?("attr_reader with a splat")
end
puts "after"
"a".unicode_normalize(:nfd)
puts "not reached"
