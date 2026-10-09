# spinel: share
# A `tap` block parameter that is CELLED, and the cell nobody filled.
#
# `StringIO.new.tap { |body| ... }` crashed with SIGSEGV, and only when three
# methods that main never calls were compiled beside it (#4418). Replacing the
# StringIO with a String turned the crash into "can't modify frozen String:
# nil", which named the real symptom: the block parameter arrived nil.
#
# What the unused methods change is the TYPE of `response`. They make it poly,
# so `response.read_body` becomes a dispatch over a class switch, and one arm
# hands the inner block over as a proc rather than splicing it. That makes the
# `tap` parameter a captured local -- backed by a heap cell -- and every read
# in the body goes through the cell:
#
#     lv_body = _t1;                             <- the binding writes the SLOT
#     *_cell_body = NULL;                        <- the cell starts empty
#     sp_StringIO_shl((*_cell_body), lv_chunk);  <- the read goes to the CELL
#
# The publish from slot to cell existed, at the capture fill, which is only
# reached when a proc is actually built; the arms that splice the block inline
# read the cell without one ever having been built. The loop emitters learned
# this before (doom's build_composite, where a nested block saw nil on the
# first pass) and publish at the top of the body. `tap` and `then` splice their
# body themselves and never went through that prologue, so the rule was there
# and the position was missing.
#
# The program is the reporter's, from ONCE Campfire's Opengraph::Fetch. It is
# kept whole rather than reduced because the reduction stops celling the
# parameter: what makes this shape is a poly receiver whose dispatch needs BOTH
# a spliced arm and a proc arm, and that took all three of the unused methods
# to arrange.
require "stringio"

class HTTPResponse
  def initialize(code, body)
    @code = code
    @body = body
  end
end
class HTTPOK < HTTPResponse; end
class HTTPFound < HTTPResponse; end

class HTTPResponse
  def read_body
    if block_given?
      offset = 0
      total = @body.bytesize
      while offset < total
        yield @body.byteslice(offset, 4).to_s
        offset += 4
      end
    end
    @body
  end
end

class Conn
  def self.open(x)
    c = Conn.new
    yield c
  end

  def build(code, body)
    case code
    when "200" then return HTTPOK.new(code, body)
    when "302" then return HTTPFound.new(code, body)
    end
    HTTPResponse.new(code, body)
  end

  def request(code, body)
    res = build(code, body)
    yield res if block_given?
    res
  end
end

class Fetch
  MAX_BODY_SIZE = 100

  def fetch_document(code)
    fetch(code) do |response|
      return body_if_acceptable(response)
    end
  end

  def fetch(code)
    3.times do
      Conn.open(code) do |http|
        http.request(code, "<body>ok<body>") do |response|
          if response.is_a?(HTTPFound)
            code = "200"
          else
            yield response
          end
        end
      end
    end
    raise "too many"
  end

  def body_if_acceptable(response)
    size_restricted_body(response) if response.is_a?(HTTPOK)
  end

  def size_restricted_body(response)
    StringIO.new.tap do |body|
      response.read_body do |chunk|
        body << chunk
      end
    end.string
  end
end

puts Fetch.new.size_restricted_body(HTTPOK.new("200", "<body>ok<body>")).inspect
puts "done"
