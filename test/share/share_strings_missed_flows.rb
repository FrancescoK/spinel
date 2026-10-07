# Flag-only. Each String below reaches a second name through a flow the
# share analysis did not follow: a pattern binding, a global alias, or a
# builtin that keeps what it is handed (Hash.new's default and block,
# Enumerator.new's yielder, an OpenStruct's fields, zip's pairs, flatten's
# elements, instance_eval's ivars). share_strings_break_values.rb has the
# break and next values. The analysis neither
# joined the two names nor treated the flow as unknown, so each held its
# own copy and a change through one did not show through the other. Each
# case runs in a method of its own, so no other case's names join its own.

# a pattern binds a part of the value it matches
def pattern_array
  s = +"ab"
  case [s]
  in [t]
    t << "g"
  end
  p s
end
def pattern_later_element
  n = 1
  s = +"ab"
  case [n, s]
  in [Integer, t] then t << "h"
  end
  p s
end
def pattern_hash
  s = +"ab"
  case { a: [s] }
  in { a: [t] }
    t << "i"
  end
  p s
end
def pattern_rightward
  s = +"ab"
  [s] => [t]
  t << "j"
  p s
end
def pattern_predicate
  s = +"ab"
  if [1, s] in [Integer, u]
    u << "k"
  end
  p s
end
def pattern_find
  s = +"ab"
  case [1, s, 2]
  in [*, String => t, *]
    t << "l"
  end
  p s
end
pattern_array
pattern_later_element
pattern_hash
pattern_rightward
pattern_predicate
pattern_find

# `alias $b $a` makes $b the global $a
alias $b $a
def global_alias
  s = +"ab"
  $a = s
  $b << "m"
  p s
end
global_alias

# Hash.new's default and its block's value are what a missing key reads,
# and the block is handed the key the read asks for
def hash_default
  s = +"ab"
  h = Hash.new(s)
  h[:x] << "n"
  p s
end
def hash_block_value
  s = +"ab"
  h = Hash.new { |hh, k| s }
  h[:missing] << "o"
  p s
end
def hash_block_key
  h = Hash.new { |hh, k| k << "p" }
  s = +"ab"
  h[s]
  p s
end
def hash_values_at_key
  h = Hash.new { |hh, k| k << "q" }
  s = +"ab"
  h.values_at(s)
  p s
end
hash_default
hash_block_value
hash_block_key
hash_values_at_key

# what an Enumerator's block pushes to its yielder is what next answers
def enumerator_yielder
  s = +"ab"
  e = Enumerator.new { |y| y << s }
  e.next << "r"
  p s
end
enumerator_yielder

# an OpenStruct reads back the String it was given
require "ostruct"
def ostruct_new
  s = +"ab"
  o = OpenStruct.new(name: s)
  o.name << "s"
  p s
end
def ostruct_writer
  s = +"ab"
  o = OpenStruct.new
  o.title = s
  o.title << "t"
  p s
end
ostruct_new
ostruct_writer

# zip pairs the receiver's elements with the argument's
def zip_pair
  s = +"ab"
  [1].zip([s])[0][1] << "u"
  p s
end
def zip_block
  s = +"ab"
  [1].zip([s]).each { |a, b| b << "v" }
  p s
end
zip_pair
zip_block

# flatten's answer holds the nested Arrays' elements themselves
def flatten_block
  s = +"ab"
  [[s]].flatten.each { |x| x << "w" }
  p s
end
def flatten_index
  s = +"ab"
  [[1, [s]]].flatten[1] << "x"
  p s
end
flatten_block
flatten_index

# an instance_eval block's ivar is its receiver's
class Keeper
  def k = @k
end
k = Keeper.new
s = +"ab"
k.instance_eval { @k = s }
s << "y"
p k.k
