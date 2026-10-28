# A method answering a new String hands the caller that String, not a
# String it read on the way (the caller picks up the published handle).
class Resp
  attr_reader :body
  def initialize(b)
    @body = b
  end
end

module H
  def self.token(resp)
    body = resp.body
    marker = "value=\""
    at = body.index(marker)
    raise "none" if at.nil?

    start = at + marker.size
    stop = body.index("\"", start)
    raise "unterminated" if stop.nil?

    body[start, stop - start].to_s
  end

  def self.token_bytes(resp)
    body = resp.body
    marker = "value=\""
    at = body.index(marker)
    start = at + marker.size
    stop = body.index("\"", start)
    body.byteslice(start, stop - start).to_s
  end

  def self.token_return(resp)
    body = resp.body
    marker = "value=\""
    at = body.index(marker)
    start = at + marker.size
    stop = body.index("\"", start)
    return body[start, stop - start].to_s
  end

  def self.token_rescue(resp)
    body = resp.body
    marker = "value=\""
    at = body.index(marker)
    start = at + marker.size
    stop = body.index("\"", start)
    return body[start, stop - start].to_s
  rescue StandardError
    "error"
  end

  def self.same(resp)
    s = resp.body
    s.to_s
  end

  def self.kept(n)
    "x#{n}".tap { |s| $kept = s }
  end
end

module C
  BUSY = "busy"
  def self.text(n)
    line = "v: #{n}"
    return line if n == 0

    "#{line}; #{BUSY}"
  rescue StandardError => e
    "error: #{e.message}"
  end

  def self.failed(n)
    raise "boom #{n}"
  rescue StandardError => e
    "error: #{e.message}; #{BUSY}"
  end
end

r = Resp.new(+"<input value=\"abc123\">")
h = {
  "a" => H.token(r),
  "b" => H.token_bytes(r),
  "c" => H.token_return(r),
  "d" => H.token_rescue(r),
  "e" => H.same(r),
  "f" => C.text(ARGV.size + 1),
  "g" => C.text(ARGV.size),
  "h" => C.failed(ARGV.size + 1),
  "i" => H.kept(ARGV.size + 1),
}
$kept << "y"
h.each { |k, v| puts "#{k}: #{v}" }
puts C.text(ARGV.size + 1)
