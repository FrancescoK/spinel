# A String handed through a POLY parameter and stored into an ivar, a class
# variable or a global that the program appends to: the variable is another
# name for the caller's String, as a local alias is, so the append reaches it.
# Before, the store took a copy, the append was lost, and nothing refused.
# A class method's ivar is the class object's, apart from an instance's; a
# class body's `@@s` is the class's. The Integer calls keep the parameters
# POLY.
class StoreIvar
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    keep(data)
  end
  def keep(v)
    @s = v
    @s << "!"
    nil
  end
end
class StoreIvarLater
  def keep(v)
    @s = v
    nil
  end
  def grow = (@s << "?")
end
class StoreCvar
  @@s = nil
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    @@s = data
    @@s << "#"
    nil
  end
end
class StoreGvar
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    $poly_store = data
    $poly_store << "%"
    nil
  end
end
class StoreReassign
  def entry(data)
    return data.to_s if data.is_a?(Integer)
    @s = data
    @s = +"other"
    @s << "!"
    @s
  end
end
class StoreClassIvar
  def self.keep(v)
    return v.to_s if v.is_a?(Integer)
    @s = v
    nil
  end
  def self.grow = (@s << "&")
end
class StoreClassBody
  x = [1, +"g"].last
  x = 2 if x.nil?
  @@s = x
  def self.grow = (@@s << "*")
  grow
  $class_body_store = x
end
a = +"a"
StoreIvar.new.entry(1)
StoreIvar.new.entry(a)
b = +"b"
later = StoreIvarLater.new
later.keep(1)
later.keep(b)
later.grow
c = +"c"
StoreCvar.new.entry(1)
StoreCvar.new.entry(c)
d = +"d"
StoreGvar.new.entry(1)
StoreGvar.new.entry(d)
e = +"e"
StoreReassign.new.entry(1)
r = StoreReassign.new.entry(e)
f = +"f"
StoreClassIvar.keep(1)
StoreClassIvar.keep(f)
StoreClassIvar.grow
p a, b, c, d, e, r, f, $class_body_store
