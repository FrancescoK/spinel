# A boxed receiver's String search answers nil where it finds nothing, also
# when the program defines a method of the same name: a String#byteindex
# polyfill in a module String includes only where the builtin is missing. The
# call is then typed as a boxed value, and the String's answer, an Integer
# that can be nil, is boxed with its nil.

unless "".respond_to?(:byteindex)
  String.include(
    Module.new {
      def byteindex(needle, offset = 0) = bytesize
      def byterindex(needle, offset = 0) = 0
    }
  )
end

def suffix(s, o) = o > 100 ? 1 : s.byteslice(o, s.bytesize - o)

def find(s, needle)
  line = suffix(s, 2)
  i = line.byteindex(needle)
  return :none if i.nil?
  i + needle.bytesize
end

def last(s, needle)
  line = suffix(s, 0)
  j = line.byterindex(needle)
  j.nil? ? :none : j
end

p find("hello world", "wor")
p find("hello world", "zzz")
p last("hello world", "o")
p last("hello world", "q")
