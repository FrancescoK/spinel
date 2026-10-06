# A redo runs a while loop's body again without its condition, so a fact
# the condition proved (`while x`, `while i < a.size`) does not hold where
# the body starts: a nil written before the redo reads as nil there.

# `while x` proves x non-nil only for a body the condition let in.
def guard(z)
  x = 5
  done = false
  while x
    p x
    puts(x > 0)
    unless done
      done = true
      x = z
      redo
    end
    break
  end
rescue NoMethodError
  puts "NoMethodError"
end
guard(7)
guard(nil)

# until, and a Float
def until_guard(z)
  x = 1.5
  done = false
  until x.nil?
    puts(x < 9)
    unless done
      done = true
      x = z
      redo
    end
    break
  end
rescue NoMethodError
  puts "NoMethodError"
end
until_guard(2.5)
until_guard(nil)

# `i < a.size` proves a[i] an element only while the index stays in range
def index_redo(z)
  a = [3, 1]
  i = 0
  done = false
  while i < a.size
    v = a[i]
    p v
    puts(v > 0)
    unless done
      done = true
      i += 9 if z.nil?
      redo
    end
    i += 1
  end
rescue NoMethodError
  puts "NoMethodError"
end
index_redo(1)
index_redo(nil)

# A redo of a nested block or loop runs that one again, and the outer
# loop's condition still holds in its body.
def nested(x)
  while x
    [1].each do |k|
      redo if k > 1
    end
    p x + 1
    x = nil
  end
end
nested(4)
