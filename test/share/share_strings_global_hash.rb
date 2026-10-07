# Flag-only. A String stored into a global Hash or Array is the element
# itself, so a change through the container shows in every name that holds
# it. Where the share rule shares the container's values, the global's
# container takes a variable's handle, and a fresh String it is given is
# wrapped as a handle of its own. The flag used to refuse these programs,
# as the default build does (a global's container holds no handle there).
# Each case runs in a method of its own.
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

# a fresh String a global's Hash or Array is given is a handle of its own
# where the rule shares the container's values
def hash_fresh_value
  $fe = {}
  $fe["a"] = +""
  $fe["a"] << "x"
  puts $fe["a"]
end
hash_fresh_value

def array_fresh_push
  $fg = []
  $fg.push(+"y")
  $fg.unshift(+"z")
  $fg.each { |y| y << "?" }
  p $fg
end
array_fresh_push

def array_fresh_literal
  $fh = [+"q", +"r"]
  $fh[1] << "!"
  $fh.each { |y| y << "." }
  p $fh
end
array_fresh_literal
