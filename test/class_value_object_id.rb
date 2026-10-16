# A class value's object_id is an Integer that stays the same for the class,
# whether the class is held typed, in a local, in an Array or as a Hash key,
# and differs between classes.
class B
  p self.object_id.is_a?(Integer)
end
class C; end
k = B
p k.object_id == B.object_id, B.object_id == C.object_id, B.__id__ == B.object_id
p String.object_id == String.object_id, String.object_id == Integer.object_id
list = [B, C, 1, "s"]
p list[0].object_id == B.object_id, list[1].object_id == B.object_id
h = { B => 1 }
p h.keys.first.object_id == B.object_id
