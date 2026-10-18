# A block's return leaves the method the block is written in, also when
# the method that yields it is spliced in and yields inside begin/ensure
# behind an early `return self unless block_given?`: the ensure runs, and
# the return does not stop at the spliced method (#9511, Net::HTTP.start's
# shape).
$log = []
class Session
  def start
    return self unless block_given?
    begin
      yield self
    ensure
      finish
    end
  end

  def finish = ($log << :finish; nil)

  # its own return in the protected body leaves only this method
  def own
    return :early unless block_given?
    begin
      return :own if yield(1) == 1
      :tail
    ensure
      $log << :own_ensure
    end
  end
end

def fetch
  Session.new.start { |s| return "returned from fetch" }
  "the return was lost"
end
p fetch

# an ensure of the caller's own around the call runs after the session's
def fetch_outer
  begin
    Session.new.start { |s| return :outer }
  ensure
    $log << :outer_ensure
  end
  :lost
end
p fetch_outer

def own_value
  r = Session.new.own { |x| x }
  [r, :after]
end
p own_value

# an Integer answer through the session
def count
  Session.new.start { |s| return 42 }
  0
end
p count + 1

# two spliced methods, each behind its ensure
class Pool
  def with
    return nil unless block_given?
    begin
      Session.new.start { |s| yield s }
    ensure
      $log << :pool
    end
  end
end

def deep
  Pool.new.with { |s| return :deep }
  :lost
end
p deep

# no return taken: the block's value
def plain = Session.new.start { |s| :value }
p plain
p $log
