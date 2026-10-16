# A rescued exception's #class walks a user parent class: #superclass and
# #ancestors no longer skip from the class straight to StandardError.
class Bad < StandardError; end
class Invalid < Bad; end
module Admin
  class Oops < Invalid; end
end

begin
  raise Invalid, "x"
rescue => e
  p e.class
  p e.class.superclass
  p e.class.superclass.superclass
  p e.class.ancestors.first(3)
  p e.class == Invalid
  p e.class <= Bad
  p e.class.name
end

begin
  raise Admin::Oops, "y"
rescue => e
  p e.class.superclass
  p e.class.ancestors.first(4)
end

begin
  raise ArgumentError, "z"
rescue => e
  p e.class.superclass
end

# a receiver typed as the user class (`rescue Bad => e`, a plain instance)
begin
  raise Invalid, "w"
rescue Bad => e
  p e.class.superclass
  p e.class.ancestors.first(3)
end
p Invalid.new("q").class.superclass

# #new on the rescued class builds that class, not user class 0
begin
  raise Invalid, "v"
rescue => e
  p e.class.new("again").class
end

# an included module sits in the ancestors before the parent
module Tag; end
class Tagged < Bad
  include Tag
end
begin
  raise Tagged, "t"
rescue => e
  p e.class.ancestors.first(4)
end
