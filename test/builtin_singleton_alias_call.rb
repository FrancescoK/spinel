# A singleton alias of a builtin's class method answers like the builtin's own
# call: `class << File; alias basename_copy basename; end` then
# `File.basename_copy(path)` was refused. Through a constant, a constant path,
# a local that holds the class, `self` in a class method, an alias of an alias,
# `alias_method`, `singleton_class.alias_method`, with a block or keywords.
# An alias captures the method in effect where it appears: a `def self.now`
# written before it is what the alias runs (`Dir.cur`), and one written
# before a later `def` of the builtin's name keeps the builtin (`File.basename`
# wrapper, `Time.now`). A call that runs before the alias is made finds no
# method, as in CRuby (the first line).
p((Time.stamp rescue :nomethod))
class File
  class << self
    alias basename_copy basename
  end
end
p File.basename_copy("dir/name")
p File.basename_copy("dir/name.rb", ".rb")

class Time
  class << self
    alias stamp now
    alias stamp2 stamp
    alias_method :stamp3, :stamp2
    alias_method :mk_at, :at
    def self_stamp = self.stamp.class
  end
end
class << Time
  def again = stamp.class
end
p Time.stamp.class, ::Time.stamp.class, Time.stamp2.class, Time.stamp3.class
p Time.self_stamp, Time.again
p Time.stamp(in: "+09:00").utc_offset
p Time.mk_at(0).to_i, Time.mk_at(0, in: "+01:00").utc_offset

class String
  class << self
    alias_method :mk, :new
  end
end
p String.mk("x"), String.mk

class Array
  singleton_class.alias_method :mk, :new
end
p Array.mk(2, 7), Array.mk(2) { |i| i * 3 }

class Integer
  class << self
    alias_method :root, :sqrt
  end
end
p Integer.root(16)
k = Integer
p k.root(25)

class Dir
  def self.pwd = :mine
  class << self
    alias_method :cur, :pwd
  end
end
p Dir.cur, Dir.pwd

class File
  class << self
    alias original_basename basename
    def basename(path) = "wrapped:#{original_basename(path)}"
  end
end
p File.basename("dir/name"), File.basename_copy("dir/name")

class << Time
  alias_method :stamp6, :now
  def now = :mine_now
  alias_method :stamp7, :now
end
p Time.stamp6.class, Time.now, Time.stamp7, Time.stamp.class

class Hash
  class << self
    alias_method :mk, :new
    alias_method :mk2, :mk
    def mk = :user_mk
  end
end
p Hash.mk, Hash.mk2, Hash.mk2(0)

p Array.mk(1, 1).class
