# A Hash, Array or String subclass answers an alias the program's reopen of
# its builtin adds, as the builtin does: activesupport aliases blank? to
# empty? on Hash, Array and String, and its HashWithIndifferentAccess,
# OrderedOptions and StringInquirer are subclasses of them. A subclass with
# aliases of its own that does not redefine the target (Indiff, as
# HashWithIndifferentAccess aliases regular_writer) is not refused: the alias
# by name is the builtin's.
class Hash
  alias_method :blank?, :empty?
end
class Array
  alias_method :blank?, :empty?
end
class String
  alias_method :blank?, :empty?
end

class Opts < Hash
  def [](k) = super(k.to_sym)
end
class Indiff < Hash
  alias_method :regular_writer, :[]=
  def []=(k, v)
    regular_writer(k.to_s, v)
  end
end
class List < Array
  def second = self[1]
end
class Name < String
  def shout = upcase
end

o = Opts.new
p o.blank?
o[:a] = 1
p o.blank?, o["a"]
i = Indiff.new
p i.blank?
i[:b] = 2
p i.blank?, i["b"]
l = List.new
p l.blank?
l << 1 << 2
p l.blank?, l.second
p Name.new("").blank?, Name.new("x").blank?, Name.new("x").shout
p({}.blank?, [].blank?, "".blank?)
