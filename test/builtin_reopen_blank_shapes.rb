# activesupport's blank.rb, minus its Concurrent::Map cache: a reopen of
# Object, NilClass, FalseClass, TrueClass, Array, Hash, Symbol, String,
# Numeric and Time, each defining blank? / present?, where present? calls
# the reopen's own blank? receiverless and Array / Hash / Symbol alias
# blank? to the builtin empty?. Every receiver kind below has to reach ITS
# class's definition (nil.blank? is true, not Object's false), and a
# receiver the program never reopened for (Integer, Float) has to reach
# Numeric's.
class Object
  def blank? = respond_to?(:empty?) ? !!empty? : false
  def present? = !blank?
  def presence
    self if present?
  end
end

class NilClass
  def blank? = true
  def present? = false
  def tag(t) = "n"
end

class FalseClass
  def blank? = true
  def present? = false
end

class TrueClass
  def blank? = false
  def present? = true
end

class Array
  alias_method :blank?, :empty?
  def present? = !empty?
end

class Hash
  alias_method :blank?, :empty?
  def present? = !empty?
end

class Symbol
  alias_method :blank?, :empty?
  def present? = !empty?
end

class String
  BLANK_RE = /\A[[:space:]]*\z/
  def blank? = empty? || BLANK_RE.match?(self)
  def present? = !blank?
  def tag(t) = blank? ? t.downcase : "s"
end

class Numeric
  def blank? = false
  def present? = true
end

class Time
  def blank? = false
  def present? = true
  def tag(t) = "t#{t}"
end

class Thing; end
class Bag
  def empty? = true
end

p "".blank?
p " \t\n".blank?
p "x".blank?
p "x".present?
s = +""
s << " "
p s.blank?
p nil.blank?
p nil.present?
p false.blank?
p true.blank?
p true.present?
p [].blank?
p [1].blank?
p [1].present?
p({}.blank?)
p({ a: 1 }.present?)
p :"".blank?
p :a.blank?
p :a.present?
p 0.blank?
p 5.present?
p 2.5.blank?
p Time.now.blank?
p Thing.new.blank?
p Thing.new.present?
p Bag.new.blank?
p "x".presence
p "".presence

# The same through a poly receiver: the dispatch switches on the boxed
# value's tag and class, so nil, a bool, a String, a Symbol, an Integer, a
# Float, an Array, a Hash, a Time and a user object each reach their own
# blank? / present? (or Object's, for the classes with no reopen).
xs = ["", " ", "x", nil, false, true, [], [1], {}, { a: 1 }, :"", :a, 0, 2.5, Time.now, Thing.new, Bag.new]
xs.each { |x| print x.blank? ? "B" : "p" }
puts
xs.each { |x| print x.present? ? "P" : "b" }
puts
# ... and with an argument (a separate arm builder), where the classes
# without a tag of their own fall to Object's
class Object
  def tag(t) = blank? ? t : "-"
end
xs.each { |x| print x.tag("B") }
puts
