# A mixin the class table does not record gives a builtin its module's
# constants all the same: an include under a condition, in a case arm, in a
# block, and a bare one at the top level (Object's, so every class sees it).
# Each is read through the builtin as CRuby does, while a name no module
# gives to the builtin stays a NameError.
class Foo
  def self.v = 9
end
class Bar
  def self.v = 2
end
class Baz
  def self.v = 3
end
class Qux
  def self.v = 4
end
module Ma; MA = Foo; end
module Mb; MB = Bar; end
module Mc; MC = Baz; end
module Md; MD = Qux; end

class String
  include Ma if Foo.v == 9
end
class Hash
  1.times { include Mb }
end
class StandardError
  case Foo.v
  when 9 then include Md
  end
end
include Mc

def try
  p yield
rescue NameError => e
  puts "NameError: #{e.message}"
end

try { String::MA.v }
try { Hash::MB.v }
try { ArgumentError::MD.v }
try { Symbol::MC.v }
try { String::Foo.v }
try { Comparable::Bar.v }
