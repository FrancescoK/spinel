# A call's answer changed in place through a shadow copy that the shim
# writes back into the handle: the shadow's reads declare themselves, and
# the check reports nothing here (the bang's own answer is dropped).
def pick(value, missing)
  return nil if missing
  value
end
s = +"ab"
[false, true].each do |missing|
  begin
    pick(s, missing).upcase!
  rescue NoMethodError => e
    p e.class
  end
end
p s
