# A yielding helper tests its block's value (`raise ... unless yield`), and
# the block calls a method no class defines. CRuby raises NoMethodError from
# the block. The condition was refused as non-bool when this was the only call
# site, and beside a site whose block answers a bool, the raising block was
# negated with `!` and the C did not compile.
class Gadget
end

module Chk
  def self.check(label)
    raise "FAIL: #{label}" unless yield
    puts "ok #{label}"
  end

  def self.when_true(label)
    puts "yes #{label}" if yield
  end
end

module Solo
  def self.check(label)
    raise "FAIL: #{label}" unless yield
    puts "ok #{label}"
  end
end

Chk.check("typed") { 1 + 1 == 2 }
begin
  Chk.check("unresolved") { Gadget.new.save(1) }
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

Chk.when_true("typed") { true }
begin
  Chk.when_true("unresolved") { Gadget.new.refresh }
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

begin
  Solo.check("only site") { Gadget.new.save(2) }
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
