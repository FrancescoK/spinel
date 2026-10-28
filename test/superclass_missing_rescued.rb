# the NameError of a superclass that names nothing where the header
# stands can be rescued; a constant of another module (a class or a
# module) does not count, and a later header, once the superclass exists,
# makes the class
module Views
  class Other; end
  module Mod; end
end
begin
  module Search
    class ByOther < Other; end
  end
rescue NameError => e
  puts "#{e.class}: #{e.message}"
end
begin
  module Search
    class ByMod < Mod; end
  end
rescue NameError => e
  puts "#{e.class}: #{e.message}"
end
# `::Missing` is looked up in Object alone
class Holder
  begin
    K = Class.new(::Missing)
  rescue NameError => e
    puts "#{e.class}: #{e.message}"
  end
end
begin
  class Bypass < Base
    puts "body"
  end
rescue NameError => e
  puts "#{e.class}: #{e.message}"
end
class Base; end
class Bypass < Base; def hi = "hi"; end
p Bypass.superclass
puts Bypass.new.hi
