# Flag-only. A break value is the value of the loop or the call it leaves,
# so the name that takes that value names the String itself. The share
# analysis sent the value to UNKNOWN but joined the receiving side to
# nothing, so the name held a copy and the change did not show in s. Each
# case runs in a method of its own, so no other case's names join its own.
def break_while
  s = +"ab"
  r = while true
    break s
  end
  r << "c"
  p s
end
def break_until
  s = +"ab"
  r = until false
    break s
  end
  r << "d"
  p s
end
def break_for
  s = +"ab"
  r = for i in [1] do break s end
  r << "e"
  p s
end
def break_hash_each
  s = +"ab"
  r = { k: 1 }.each { |k, v| break s }
  t = r
  t << "f"
  p s
end
def break_array_each
  s = +"ab"
  r = [1].each { break s }
  t = r
  t << "g"
  p s
end
break_while
break_until
break_for
break_hash_each
break_array_each
