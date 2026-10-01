# The nil narrowing's flag rule and its nil-free arrays (#6481 follow-up).

# A nil written to lo after `found = true`: the `found = false` further up
# does not make the nil safe, since found is true again by then.
def after_true(k)
  found = false
  lo = nil
  lo = k
  found = true
  lo = nil
  if found
    p lo.is_a?(Integer)
    p lo.nil?
  end
end
after_true(3)

# A nil write that overwrites the non-nil one before `found = true`.
def overwritten(k, key)
  m = 1
  m = nil if key != :a
  found = false
  lo = nil
  lo = k
  lo = m
  found = true
  if found
    p lo.is_a?(Integer)
  end
end
overwritten(3, :a)
overwritten(3, :b)

# The flag pair kept apart as intended still answers.
def kept(a)
  found = false
  lo = nil
  a.each do |v|
    if !found || v < lo
      lo = v
      found = true
    end
  end
  found ? lo.is_a?(Integer) : :none
end
p kept([3, 1, 2])
p kept([])

# each_slice and each_cons answer their receiver when given a block: a gap
# written through that value is a gap in the array.
def slice_alias
  a = [1, 2, 3]
  b = a.each_slice(2) { |s| }
  b[5] = 9
  i = 0; r = []
  while i < a.size
    r << a[i].is_a?(Integer); i += 1
  end
  r
end
p slice_alias
def cons_alias
  a = [4, 5]
  b = a.each_cons(1) { |s| }
  b[3] = 9
  i = 0; r = []
  while i < a.size
    r << a[i].is_a?(Integer); i += 1
  end
  r
end
p cons_alias
