# An each that answers `to_enum` without a block and wraps its loop in a
# begin with rescue / ensure: its enumerator runs the method's body in a
# fiber, where the begin's nil answer meets the Enumerator-typed result.

class Readable
  def initialize(chunks) = @chunks = chunks
  def read = @chunks.shift
  def close(error = nil) = @closed = true
  def closed? = @closed

  def each
    return to_enum unless block_given?
    begin
      while chunk = read
        yield chunk
      end
    rescue => error
      raise
    ensure
      close(error)
    end
  end
end

r = Readable.new(["a", "b"])
p r.each.to_a
p r.closed?
p Readable.new(["c"]).each { |c| c }
e = Readable.new(["d", "e"]).each
p e.next
p e.next
