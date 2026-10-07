# Flag-only. A next value is its block's value, and a break out of a
# yielding method's block that method call's value, so the name that takes
# it names the String itself. These answered right while break and next
# values joined UNKNOWN; they now answer right through the flow the share
# analysis follows (share_strings_break_values.rb has the loops).
def run_block = yield
def break_user_method
  s = +"ab"
  r = run_block { break s }
  r << "h"
  p s
end
def next_map
  s = +"ab"
  r = [1].map { |x| next s }
  r[0] << "i"
  p s
end
def next_map_param
  s = +"ab"
  r = [s].map { |x| next x }
  r[0] << "j"
  p s
end
break_user_method
next_map
next_map_param
