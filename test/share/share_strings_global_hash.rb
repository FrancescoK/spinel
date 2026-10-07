# Flag-only. A String variable stored into a global Hash is the Hash's value
# itself, so a change through the Hash shows in the variable. The global's
# Hash takes the variable's handle where the share rule shares the String,
# where the flag used to refuse the program as the default build does (a
# global's Hash holds no handle there). Each case runs in a method of its
# own.
def hash_index_store
  s = +"v"
  $fb = {}
  $fb["k"] = s
  $fb["k"] << "!"
  p s, $fb
end
hash_index_store

def hash_literal_value
  s = +"w"
  $fc = { "k" => s }
  $fc["k"] << "?"
  p s
end
hash_literal_value

def hash_store_call
  s = +"m"
  $fd = {}
  $fd.store("k", s)
  $fd["k"].upcase!
  p s, $fd
end
hash_store_call
