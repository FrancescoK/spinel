# A user method named throw can return a value, including at the tail of a
# catch or a yielded block. Its name alone does not make the block diverge.
def throw(tag, value)
  value
end

def relay
  yield
end

p catch(:tag) { throw(:tag, 7) }
p relay { throw(:tag, 8) }
p relay {
  case 1
  when 1 then throw(:tag, 9)
  else throw(:tag, 10)
  end
}
