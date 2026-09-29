# A boxed receiver calling a Socket::Option or Addrinfo reader name with
# arguments is not that reader: no class here defines it, so the call
# compiles and raises NoMethodError instead of refusing the program.

class Chip
  def initialize
    @a = 1
    @b = 2
  end

  def save_state(out)
    out.int(@a)
    out
  end

  def save_level(out)
    out.level(@a, @b)
    out
  end

  def describe(addr)
    addr.ip_port(@a)
  end
end

def pick(n)
  n > 0 ? n : "str"
end

chip = Chip.new
[1, -1].each do |n|
  v = pick(n)
  begin
    chip.save_state(v)
  rescue NoMethodError => e
    puts e.message
  end
  begin
    chip.save_level(v)
  rescue NoMethodError => e
    puts e.message
  end
  begin
    chip.describe(v)
  rescue NoMethodError => e
    puts e.message
  end
end
puts "done"
