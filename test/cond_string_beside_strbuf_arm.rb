# A conditional whose arms are a String and a String handle: a narrowed
# box's dup (a String) beside String.new (a handle), into a local that is
# a handle itself. The arms went into one C conditional as they stood, a
# const char * beside an sp_String *, and the String.new arm read garbage.
def dup_or_new(to)
  s = if to.is_a?(String)
        to.dup
      else
        String.new
      end
  s << "!"
  s
end

def new_or_dup(to)
  s = to.is_a?(String) ? String.new : to.to_s.dup
  s << "?"
  s
end

def unless_form(to)
  s = unless to.is_a?(String)
        String.new("n")
      else
        to.dup
      end
  s << "."
  s
end

def three_arms(to)
  s = if to.is_a?(String)
        to.dup
      elsif to.is_a?(Integer)
        String.new
      else
        +"other"
      end
  s << "#"
  s
end

def into_ivar(to)
  @v = to.is_a?(String) ? to.dup : String.new
  @v << "~"
  @v
end

h = { a: "x", b: 1, c: :sym }
p dup_or_new(h[:a])
p dup_or_new(h[:b])
p dup_or_new(h[:b]).encoding
p new_or_dup(h[:a])
p new_or_dup(h[:b])
p unless_form(h[:a])
p unless_form(h[:b])
p three_arms(h[:a])
p three_arms(h[:b])
p three_arms(h[:c])
p into_ivar(h[:a])
p into_ivar(h[:b])
