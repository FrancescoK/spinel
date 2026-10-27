# A rescue clause naming a constant defined nowhere raises NameError when an
# exception reaches it, as CRuby evaluates the clause's list then, with the
# exception being handled as its cause. The clause was dropped and the
# exception fell through to the next one (#10440).
def go(n)
  raise ArgumentError, "boom #{n}"
rescue Missing::Thing => e
  puts "missing #{e.kind}"
rescue StandardError => e
  puts "std #{e.message}"
end
begin
  go(1)
rescue NameError => e
  p [e.class, e.message, e.cause.class, e.cause.message]
end

# an operand before it that matches leaves it unread
def first_matches
  raise ArgumentError, "x"
rescue ArgumentError, Nope
  "ArgumentError matched"
end
p first_matches

# one that does not match reads it
def later
  raise TypeError, "y"
rescue ArgumentError, Nope2
  "never"
end
begin
  later
rescue NameError => e
  p [e.message, e.cause.class]
end

# a body that raises nothing never reaches it
def quiet
  yield
rescue Missing3
  "never"
end
p quiet { 42 }

# before a catch-all, it is read first
def before_exception
  raise "z"
rescue Missing4, Exception
  "never"
end
begin
  before_exception
rescue NameError => e
  p [e.message, e.cause.message]
end
