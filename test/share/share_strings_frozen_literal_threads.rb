# spinel: share
# spinel: gc-minor
# Concurrent handovers keep one frozen literal handle.
def shared_literal = "thread literal"
threads = Array.new(4) do
  Thread.new do
    x = shared_literal
    begin
      x << "!"
    rescue FrozenError
    end
    x
  end
end
values = threads.map { |t| t.value }
p values.all? { |x| x.equal?(values[0]) }
