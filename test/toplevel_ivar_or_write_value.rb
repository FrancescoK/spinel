# A toplevel ivar or-write used as a value, inside a method or at the top
# level itself, reads and writes the Toplevel slot.

def memo
  x = (@memo ||= 5)
  x + 1
end
p memo
p memo

def name_of
  n = (@name ||= "top")
  n.upcase
end
p name_of

def list
  (@list ||= []) << 1
end
p list
p list

y = (@y ||= 7)
p y
@z = 3
p(@z &&= 4)
p @z
