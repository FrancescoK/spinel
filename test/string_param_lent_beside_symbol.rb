# A symbol literal spelling a method's name that nothing calls it by
# (`p :edit_into`) leaves the method's String parameter lent, so the
# appends reach the caller's buffer (#6040). A name `send` or `&:x`
# reaches keeps the plain ABI.
def user_into(io, name)
  io << "<li>" << name.to_s << "</li>"
  nil
end

def edit_into(io, names)
  io << "<ul>"
  names.each { |n| user_into(io, n) }
  io << "</ul>"
  nil
end

def edit(names)
  io = String.new
  edit_into(io, names)
  io
end

puts edit(["a", "b"])
p :edit_into
h = { user_into: 1 }
p h

def shout(s) = s.upcase
p ["a", "b"].map(&:upcase)
p send(:shout, "c")
