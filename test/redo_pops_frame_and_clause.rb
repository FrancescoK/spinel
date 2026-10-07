# A redo goes back to the top of its body. Written inside a begin, or in a
# rescue clause, it leaves that begin's frame and that clause's exception as
# well. Each method is called 200 times: a frame or a handled exception left
# behind on every redo would run its stack out.

def twice
  yield 1
  yield 2
end

def in_begin(log)
  n = 0
  [1, 2].each do |x|
    n += 1
    begin
      redo if n == 1
      log << x
    rescue IOError
      log << :no
    end
  end
  n
end

def in_two_begins(log)
  n = 0
  2.times do |i|
    n += 1
    begin
      begin
        redo if n == 1
        log << i
      rescue KeyError
        log << :no
      end
    rescue IOError
      log << :no
    end
  end
  n
end

def in_clause(log)
  n = 0
  [1, 2].each do |x|
    n += 1
    begin
      raise IOError, "again" if n == 1
      log << x
    rescue IOError
      redo
    end
  end
  log << $!.inspect
  n
end

def in_while(log)
  n = 0
  k = 0
  while k < 2
    k += 1
    n += 1
    begin
      redo if n == 2
      log << k
    rescue IOError
      log << :no
    end
  end
  n
end

def in_yield(log)
  n = 0
  twice do |x|
    n += 1
    begin
      raise IOError, "again" if n == 1
      redo if n == 2
      log << x
    rescue IOError
      redo
    end
  end
  n
end

def in_map(log)
  n = 0
  r = [1, 2].map do |x|
    n += 1
    begin
      redo if n == 1
      x * 2
    rescue IOError
      0
    end
  end
  log << r.sum
  n
end

def in_each_char(log)
  n = 0
  "ab".each_char do |ch|
    n += 1
    begin
      redo if n == 1
      log << ch
    rescue IOError
      log << :no
    end
  end
  n
end

# the loop stands in a rescue clause: that clause's exception stays
def inside_clause(log)
  n = 0
  begin
    raise KeyError, "outer"
  rescue KeyError
    [1, 2].each do |x|
      n += 1
      begin
        raise IOError, "again" if n == 1
        log << x
      rescue IOError
        redo
      end
    end
    log << $!.message
  end
  n
end

def check(name)
  log = []
  n = yield log
  puts "#{name}: #{n} #{log.inspect}"
end

check("in_begin") { |log| in_begin(log) }
check("in_two_begins") { |log| in_two_begins(log) }
check("in_clause") { |log| in_clause(log) }
check("in_while") { |log| in_while(log) }
check("in_yield") { |log| in_yield(log) }
check("in_map") { |log| in_map(log) }
check("in_each_char") { |log| in_each_char(log) }
check("inside_clause") { |log| inside_clause(log) }

total = 0
log = []
200.times do
  total += in_begin(log) + in_two_begins(log) + in_clause(log) + in_while(log)
  total += in_yield(log) + in_map(log) + in_each_char(log) + inside_clause(log)
end
puts total
puts log.size
p $!

begin
  Integer("oops")
rescue ArgumentError => e
  puts e.message
end
