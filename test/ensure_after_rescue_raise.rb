# An ensure runs when the exception leaves its begin through the rescue
# clauses: a bare `raise`, a new raise in a clause, or no clause matching.
# The clauses ran outside the begin's frame, and an exception raised there
# went straight to the caller's handler past the ensure (#8182).
def bare_reraise
  begin
    raise "x"
  rescue => e
    raise
  ensure
    puts "ensure bare-raise"
  end
end

def new_raise
  begin
    raise "x"
  rescue => e
    raise ArgumentError, "y"
  ensure
    puts "ensure new-raise"
  end
end

def unmatched
  begin
    raise "x"
  rescue ArgumentError
    puts "no"
  ensure
    puts "ensure unmatched"
  end
end

def method_level
  raise "x"
rescue => e
  raise "z"
ensure
  puts "ensure method-level"
end

def report(e) = puts("caught #{e.class}: #{e.message} cause=#{e.cause&.message.inspect}")
begin; bare_reraise; rescue => e; report(e); end
begin; new_raise; rescue => e; report(e); end
begin; unmatched; rescue => e; report(e); end
begin; method_level; rescue => e; report(e); end

# retry from a clause runs the body again; the ensure runs once, at the end
tries = 0
begin
  tries += 1
  raise "again" if tries < 3
  puts "tries #{tries}"
rescue
  retry
ensure
  puts "ensure after retry"
end

# return, break and next out of a clause still run the ensure
def ret
  begin
    raise "r"
  rescue
    return :returned
  ensure
    puts "ensure return"
  end
end
p ret
[1, 2].each do |i|
  begin
    raise "b"
  rescue
    i == 1 ? next : break
  ensure
    puts "ensure #{i}"
  end
end

# nested: the inner ensure runs before the outer clause sees the exception
begin
  begin
    begin
      raise "deep"
    rescue => e
      raise "from inner #{e.message}"
    ensure
      puts "inner ensure"
    end
  ensure
    puts "middle ensure"
  end
rescue => e
  puts "outer #{e.message}"
end

# $! in an ensure is the exception unwinding through it
begin
  begin
    raise "a"
  rescue => e
    raise "b"
  ensure
    p $!&.message
  end
rescue
end
begin
  begin
    raise "c"
  ensure
    p $!&.message
  end
rescue
end
p $!
