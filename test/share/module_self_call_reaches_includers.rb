# A module's method an include copies into its includers runs with self an
# includer, so a receiverless call there reaches the includer's method of
# the name (syswrite here, as in openssl's Buffering#do_write). The share
# walk takes the module's own method as well, where that call reached
# nothing, and the buffer it was handed, changed in place, joined what the
# walk does not follow. A String that met what the walk does not follow as
# well was then a shared String: the Method's answers here, which
# `map(&c)` keeps, were refused (#9258).
module Buffered
  def initialize
    @wbuffer = String.new
  end

  def write(s)
    @wbuffer << s
    until @wbuffer.empty?
      n = syswrite(@wbuffer)
      @wbuffer.slice!(0, n)
    end
    self
  end
end

class Pipe
  include Buffered

  def initialize(io)
    super()
    @io = io
  end

  def syswrite(data) = @io.write(data)
end

class Ledger
  include Buffered
  attr_reader :log

  def initialize
    super
    @log = String.new
  end

  def syswrite(data)
    @log << data.upcase
    data.bytesize
  end
end

r, w = IO.pipe
Pipe.new(w).write("Seongsu ").write("Station")
w.close
p r.read

ledger = Ledger.new.write("Kondae ").write("Guui")
p ledger.log

c = "Achasan".method(:center)
p [11, 13].map(&c)
