# A fill the program defines on Hash does not reach an Array: a block
# forwarded to Array#fill still runs.

class Hash
  def fill(*) = :hash_fill
end

def k(a, &b) = a.fill(0, &b)
p k([1, 2]) { |i| i + 1 }
p k([1, 2])
p({}.fill)
