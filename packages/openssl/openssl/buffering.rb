# OpenSSL::Buffering -- the IO-shaped surface over #sysread / #syswrite.
#
# Ported from CRuby's openssl/buffering.rb, whose structure this keeps: a read
# buffer filled a block at a time by #sysread, a write buffer flushed by
# #syswrite, and every reader and writer built on those two. Original
# copyright (C) 2001 GOTOU YUUZOU, licensed under the same licence as Ruby.
#
# What is different here is what the subset does not carry, and it is spelled
# out rather than approximated:
#
# * a line separator is a String, not a Regexp, and `$/` is not consulted
# * the `buf` out-parameter of #read / #readpartial is not accepted
# * the Buffer < String subclass is gone. It exists upstream to keep binary
#   encoding across `<<`, and spinel has one internal representation
# * #each is absent; #each_line is the same iterator under the name every
#   caller uses (see the note above it)
#
# Everything present behaves as CRuby's does.
#
# The contract for a class mixing this in: #sysread, #syswrite and #sysclose,
# plus #sysread_nonblock and #syswrite_nonblock for the non-blocking pair, and
# `super()` from its own #initialize. CRuby leaves the sys* primitives
# implicit because its including class is C; here a class that omits one fails
# to compile rather than at the first call, which is the better place to hear
# about it.
module OpenSSL
  module Buffering
    BLOCK_SIZE = 1024 * 16

    attr_accessor :sync

    # The including class's #initialize reaches this with `super()`, so a
    # class gets its buffers by mixing the module in and nothing else. CRuby
    # writes `initialize(*)` and forwards, which only works because its
    # including class is C; the explicit empty form is what a Ruby class has
    # to write there anyway.
    def initialize
      @eof = false
      @rbuffer = String.new
      @wbuffer = String.new
      @sync = true
    end

    # ---- reading ----

    def fill_rbuff
      chunk = sysread(BLOCK_SIZE)
      if chunk.nil? || chunk.empty?
        @eof = true
      else
        @rbuffer << chunk
      end
    end

    # `want` is a byte count, or -1 for "everything buffered". A nilable
    # integer parameter is not first class here, so nil is turned into the
    # sentinel at the boundary and never reaches the arithmetic.
    def consume_rbuff(want)
      return nil if @rbuffer.empty?
      n = want < 0 ? @rbuffer.bytesize : want
      @rbuffer.slice!(0, n)
    end

    def eof?
      fill_rbuff if !@eof && @rbuffer.empty?
      @eof && @rbuffer.empty?
    end

    def eof
      eof?
    end

    # Reads `size` bytes, or to EOF when it is nil. Answers nil at EOF when a
    # size was asked for, "" when it was not -- IO#read's contract.
    def read(size = nil)
      want = size.nil? ? -1 : size
      return "" if want == 0
      until @eof
        break if want >= 0 && want <= @rbuffer.bytesize
        fill_rbuff
      end
      ret = consume_rbuff(want)
      ret = "" if ret.nil?
      (want >= 0 && ret.empty?) ? nil : ret
    end

    # Returns as soon as ANY bytes are available: what is buffered if there is
    # anything, otherwise one sysread.
    def readpartial(maxlen)
      return "" if maxlen == 0
      return sysread(maxlen) if @rbuffer.empty?
      consume_rbuff(maxlen)
    end

    # What is buffered first, one non-blocking sysread only when it is empty --
    # CRuby's shape exactly. Anything already decrypted comes back without
    # touching the socket, which is the case a caller waiting on the
    # descriptor alone would sleep through.
    def read_nonblock(maxlen, exception: true)
      return "" if maxlen == 0
      return sysread_nonblock(maxlen, exception: exception) if @rbuffer.empty?
      consume_rbuff(maxlen)
    end

    # CRuby flushes what is buffered first, then hands the argument straight
    # to the socket: a partial write has to be the caller's to retry, and a
    # buffer standing behind it would hide how much actually went.
    def write_nonblock(s, exception: true)
      flush
      syswrite_nonblock(s, exception: exception)
    end

    def gets(eol = "\n", limit = nil, chomp: false)
      cap = limit.nil? ? -1 : limit
      idx = @rbuffer.index(eol)
      until @eof
        break unless idx.nil?
        fill_rbuff
        idx = @rbuffer.index(eol)
      end
      if eol.is_a?(String) && !idx.nil?
        size = idx + eol.bytesize
      else
        size = @rbuffer.bytesize
      end
      size = cap if cap >= 0 && cap < size
      line = consume_rbuff(size)
      return nil if line.nil?
      chomp ? line.chomp(eol) : line
    end

    # NOTE: CRuby has #each as well, aliasing this. Defining a method named
    # `each` makes spinel synthesize the Enumerable materializer
    # (__enum_to_a) for the module compiled standalone, where #gets's return
    # type collapses and the synthesized body does not typecheck. The method
    # is left out rather than worked around; #each_line is the one every
    # caller reaches for.
    def each_line(eol = "\n")
      while (line = gets(eol))
        yield line
      end
      self
    end

    def readlines(eol = "\n")
      out = []
      while (line = gets(eol))
        out << line
      end
      out
    end

    def readline(eol = "\n")
      line = gets(eol)
      raise EOFError, "end of file reached" if line.nil?
      line
    end

    def getc
      c = read(1)
      (c.nil? || c.empty?) ? nil : c
    end

    def readchar
      c = getc
      raise EOFError, "end of file reached" if c.nil?
      c
    end

    def getbyte
      c = read(1)
      (c.nil? || c.empty?) ? nil : c.ord
    end

    def readbyte
      b = getbyte
      raise EOFError, "end of file reached" if b.nil?
      b
    end

    def each_byte
      while (b = getbyte)
        yield b
      end
      self
    end

    # ---- writing ----

    def do_write(s)
      @wbuffer << s
      return if !@sync && @wbuffer.bytesize <= BLOCK_SIZE
      until @wbuffer.empty?
        n = syswrite(@wbuffer)
        break if n.nil? || n <= 0
        @wbuffer.slice!(0, n)
      end
    end

    def write(*args)
      total = 0
      args.each do |a|
        s = a.to_s
        total += s.bytesize
        do_write(s)
      end
      total
    end

    def <<(s)
      do_write(s.to_s)
      self
    end

    def print(*args)
      args.each { |a| do_write(a.to_s) }
      nil
    end

    def printf(fmt, *args)
      do_write(format(fmt, *args))
      nil
    end

    def puts(*args)
      if args.empty?
        do_write("\n")
        return nil
      end
      args.each do |a|
        s = a.to_s
        do_write(s)
        do_write("\n") unless s.end_with?("\n")
      end
      nil
    end

    def flush
      sv = @sync
      @sync = true
      do_write("")
      @sync = sv
      self
    end

    # A flush that fails does not keep close from closing, as in CRuby
    # (`flush rescue nil`): the peer that would have taken the bytes is gone,
    # and a caller that rescued the failed write still closes in an ensure.
    def close
      begin
        flush
      rescue StandardError
        nil
      end
      sysclose
      nil
    end
  end
end
