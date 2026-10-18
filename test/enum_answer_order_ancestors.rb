# Enumerable already among a superclass's ancestors, by an include of its own
# or through a module, makes a subclass's include of it (direct or through a
# module) a no-op, so the superclass's def and reader stay in front. A
# prepended module's methods and readers are in front of the class itself.
module ViaEnum
  include Enumerable
end

class UpBase
  include Enumerable
  def count = 100
  attr_reader :first
  def initialize; @first = 200; end
end

class UpKid < UpBase
  include ViaEnum
  def each; yield 5; yield 6; end
end

class ModBase
  include ViaEnum
  def count = 101
  attr_reader :first
  def initialize; @first = 201; end
end

class ModKid < ModBase
  include Enumerable
  def each; yield 5; yield 6; end
end

class BareBase
  def count = 102
end

class BareKid < BareBase
  include ViaEnum
  def each; yield 5; yield 6; end
end

module Front
  def count = 61
end

class Prepending
  include Enumerable
  prepend Front
  def each; yield 5; yield 6; end
end

module FrontReader
  attr_reader :first
end

class PrependingReader
  include Enumerable
  prepend FrontReader
  def initialize; @first = 4; end
  def each; yield 5; yield 6; end
end

p [UpKid.new.count, UpKid.new.first]
p [ModKid.new.count, ModKid.new.first]
p [BareKid.new.count, BareKid.new.first]
p Prepending.new.count
p PrependingReader.new.first
