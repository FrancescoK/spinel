# Boxed Hash presence, fetch, deletion and assignment read a shared key.
def key_read(h, key)
  h[key]
end

def key_present(h, key)
  h.key?(key)
end

def key_fetch(h, key)
  h.fetch(key, :missing)
end

def key_delete(h, key)
  h.delete(key)
end

def key_write(h, key, value)
  h[key] = value
end

# Both key kinds reach each helper, keeping its key argument boxed.
key = +"k"
alias_key = key
alias_key << "ey"
ints = { "key" => 7 }
strings = { "key" => "value" }
poly = { "key" => [9] }
mixed = { "key" => 11, :other => 12 }
p key_present(ints, key), key_present(strings, key), key_present(poly, key), key_present(mixed, key), key_present(mixed, :other)
p key_fetch(ints, key), key_fetch(strings, key), key_fetch(poly, key), key_fetch(mixed, key), key_fetch(mixed, :other)
key_write(ints, key, 17)
key_write(poly, key, [19])
key_write(mixed, :other, 22)
p key_read(ints, key), key_read(poly, key), key_read(mixed, :other)
p key_delete(ints, key), key_delete(strings, key), key_delete(poly, key), key_delete(mixed, key), key_delete(mixed, :other)
p key_present(ints, key), key_fetch(ints, key)

# An unknown alternative keeps this receiver's typed Hash storage.
write_key = +"k"
alias_write_key = write_key
alias_write_key << "ey"
boxed_key = [write_key, 0][ARGV.size]
typed = { "key" => 7 }
boxed_hash = [typed, $other][ARGV.size]
boxed_hash[boxed_key] = 17
p typed
