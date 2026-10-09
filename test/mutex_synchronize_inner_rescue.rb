# spinel: gc-stress
# spinel: share
# A rescue between Mutex#synchronize and an enclosing ensure, or an
# enclosing synchronize, catches the block's exception after the unlock
# and before the enclosing region runs; so does a modifier rescue, as a
# statement and as a value. A loop between them passes the same object on.
class CodeError < StandardError
  attr_reader :code
  def initialize(code)
    @code = code
    super("code #{code}")
  end
end

LOCK = Mutex.new
OUTER = Mutex.new

def rescue_between
  begin
    begin
      LOCK.synchronize { raise CodeError.new(9) }
    rescue CodeError => e
      p [:rescued, e.code, LOCK.locked?]
    end
    puts "after rescue"
  ensure
    puts "outer ensure ran"
  end
end

rescue_between
p LOCK.locked?

def rescue_between_locks
  OUTER.synchronize do
    begin
      LOCK.synchronize { raise CodeError.new(10) }
    rescue CodeError => e
      p [:rescued, e.code, OUTER.locked?, LOCK.locked?]
    end
    :done
  end
end

p rescue_between_locks
p [OUTER.locked?, LOCK.locked?]

def modifier_between
  begin
    LOCK.synchronize { raise CodeError.new(11) } rescue puts("rescued 11")
    v = (LOCK.synchronize { raise CodeError.new(12) } rescue 12)
    p v
  ensure
    puts "outer ensure ran"
  end
end

modifier_between
p LOCK.locked?

def loop_between(original)
  begin
    loop { LOCK.synchronize { raise original } }
  ensure
    puts "outer ensure ran"
  end
end

original = CodeError.new(13)
begin
  loop_between(original)
rescue CodeError => e
  p [e.equal?(original), e.code]
end
p LOCK.locked?
