# The message for a constant path defined nowhere names the first component
# that does not resolve, as CRuby does ("uninitialized constant A" for
# `A::B::C::D`). It once named the last two components only (the arms that
# resolve a qualified constant key on the parent's LEAF name), so a program
# that wrote `OpenSSL::SSL::VERIFY_NONE` was told about `SSL::VERIFY_NONE`, a
# string that occurs nowhere in it.
begin
  p A::B::C::D
rescue NameError => e
  puts e.message
end

begin
  p Foo::Bar::BAZ
rescue NameError => e
  puts e.message
end

# Object is still dropped: its constants are the top-level ones.
begin
  p Object::AlsoMissing
rescue NameError => e
  puts e.message
end
puts "after"
